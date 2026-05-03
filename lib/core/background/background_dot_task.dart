import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../database/app_database.dart';

const _prefsApiUrl = 'api_url';
const _prefsBeUserId = 'be_user_id';
const _prefsLastAutoDotTs = 'last_auto_dot_ts';

// 백그라운드 isolate 진입점 — 반드시 top-level 함수여야 함
@pragma('vm:entry-point')
void backgroundCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await captureAutoDot(reason: 'workmanager');
      return true;
    } catch (_) {
      return false;
    }
  });
}

/// BG isolate / continuous service 양쪽에서 공유하는 자동 dot 캡처 로직.
/// 1) 위치 수집 → 2) 로컬 DB 우선 저장 → 3) 서버 업로드 best-effort.
/// 서버 실패해도 로컬에 synced=false로 남아 다음 동기화에 합류.
Future<void> captureAutoDot({required String reason}) async {
  // 권한 확인 — 거부 상태면 조용히 종료
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  // 위치 1회 수집 — 이동 경로 회고용이라 low(~500m)면 충분, 배터리 우선.
  final Position position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 15),
      ),
    );
  } catch (_) {
    return; // 위치 수집 실패 → 이번 회차 스킵
  }

  final now = DateTime.now();
  final dotId = '${now.microsecondsSinceEpoch}_${reason.hashCode}';

  // 사용자 ID — 로컬 DB FK 용도
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(_prefsBeUserId);
  if (userId == null) return; // 로그인 정보 없음 → 종료

  // 1) 로컬 DB에 우선 저장
  final db = AppDatabase();
  final tempDayLogId = 'local_${now.year}_${now.month}_${now.day}';
  try {
    await db.upsertDayLog(DayLogTableCompanion.insert(
      id: tempDayLogId,
      userId: userId,
      date: now,
      startedAt: now,
      synced: const Value(false),
    ));
    await db.insertDot(DotTableCompanion.insert(
      id: dotId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: now,
      dayLogId: tempDayLogId,
      synced: const Value(false),
    ));
    await prefs.setInt(_prefsLastAutoDotTs, now.millisecondsSinceEpoch);
  } catch (_) {
    // 로컬 저장 실패 — 서버 시도라도 해본다 (드물게 발생)
  } finally {
    await db.close();
  }

  // 2) 서버 업로드 best-effort (오프라인이거나 토큰 만료면 다음 sync에서 일괄 처리)
  const storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  final token = await storage.read(key: 'firebase_id_token');
  if (token == null || token.isEmpty) return;

  final apiUrl = prefs.getString(_prefsApiUrl) ?? 'http://localhost:8080/v1';
  final dateStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  final dio = Dio(BaseOptions(
    baseUrl: apiUrl,
    headers: {'Authorization': 'Bearer $token'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  try {
    // 서버가 date 기반으로 daylog 자동 생성/조회.
    final res = await dio.post('/dots', data: {
      'date': dateStr,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': now.toUtc().toIso8601String(),
    });
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    final serverDayLogId = data['day_log_id'] as String?;
    final serverDotId = data['id'] as String?;
    if (serverDayLogId == null || serverDotId == null) return;

    // 3) 로컬 dot을 서버 ID로 갱신 + synced=true. 임시 daylog는 그대로 두고
    //    foreground sync 시 syncUnsyncedDots()가 dayLogId를 일치시킨다.
    final db2 = AppDatabase();
    try {
      await db2.upsertDayLog(DayLogTableCompanion.insert(
        id: serverDayLogId,
        userId: userId,
        date: now,
        startedAt: now,
        synced: const Value(true),
      ));
      // 기존 임시 row는 server dayLogId로 옮긴다.
      await db2.transaction(() async {
        await (db2.delete(db2.dotTable)..where((t) => t.id.equals(dotId)))
            .go();
        await db2.insertDot(DotTableCompanion.insert(
          id: serverDotId,
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: now,
          dayLogId: serverDayLogId,
          synced: const Value(true),
        ));
      });
    } catch (_) {
      // 갱신 실패해도 로컬 임시 row가 남아 있어 추후 sync 가능.
    } finally {
      await db2.close();
    }
  } catch (_) {
    // 네트워크/서버 오류 — 로컬 row는 synced=false로 남아 추후 sync.
  }
}
