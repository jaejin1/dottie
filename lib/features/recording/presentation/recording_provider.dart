import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/location_utils.dart';
import '../../cumulative_map/domain/place.dart';
import '../data/dot_remote_source.dart';
import '../data/dot_repository.dart';
import '../data/location_service.dart';
import '../data/geocoding_service.dart';
import '../domain/dot_model.dart';
import '../domain/recording_session.dart';
import 'dot_photo_overrides_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../timeline/domain/day_log_model.dart';

part 'recording_provider.g.dart';

// 오늘 dot이 있는 세션 (null = 오늘 첫 dot 전)
@riverpod
class ActiveRecording extends _$ActiveRecording {
  /// notifier dispose 여부 — _pollPhotoVariants 같은 fire-and-forget 작업이
  /// dispose 후에도 state 를 set 하면 에러나므로 가드로 사용.
  bool _disposed = false;

  @override
  Future<RecordingSession?> build() async {
    ref.onDispose(() => _disposed = true);

    // BE UUID 준비까지 대기 — Firebase UID 폴백은 로컬 DB(userId=BE UUID) 와
    // mismatch 되어 첫 SSO 로그인 시 today session 이 비는 원인이었음.
    final dottie = await ref.watch(currentDottieUserProvider.future);
    if (dottie == null) return null;
    final userId = dottie.uid;

    final repo = ref.read(dotRepositoryProvider);

    // 백그라운드 자동기록/오프라인에서 쌓인 미동기화 dot 을 먼저 서버로 올린다.
    // BG isolate 는 만료된 Firebase 토큰으로 직접 업로드에 실패할 수 있는데,
    // 여기가 그 dot 들을 복구하는 유일한 지점이다.
    try {
      await repo.syncUnsyncedDots();
    } catch (e) {
      debugPrint('[ActiveRecording] syncUnsyncedDots failed: $e');
    }

    final now = DateTime.now();

    // 서버 우선 복원
    final serverToday = await repo.restoreTodayFromServer();
    if (serverToday != null && serverToday.dots.isNotEmpty) {
      // sync 가 실패(오프라인)해서 로컬에만 있는 dot 병합 — BG 자동기록 dot 이
      // 다음 sync 까지 화면에서 사라지지 않도록.
      final pending = await repo.getUnsyncedDotsForDate(now);
      if (pending.isEmpty) {
        return RecordingSession(
          dayLogId: serverToday.id,
          dots: serverToday.dots,
        );
      }
      final serverIds = serverToday.dots.map((d) => d.id).toSet();
      final merged = [
        ...serverToday.dots,
        ...pending.where((d) => !serverIds.contains(d.id)),
      ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return RecordingSession(dayLogId: serverToday.id, dots: merged);
    }

    // 오프라인 폴백 — 로컬 DB. BG 자동기록 dot 은 임시 daylog 에 붙어 있어
    // getDayLogByDate 결과에 안 잡힐 수 있으므로 미동기화 dot 도 합친다.
    final dayLog = await repo.getDayLogByDate(now, userId);
    final pending = await repo.getUnsyncedDotsForDate(now);
    final baseDots = dayLog?.dots ?? const <Dot>[];
    final baseIds = baseDots.map((d) => d.id).toSet();
    final allDots = [
      ...baseDots,
      ...pending.where((d) => !baseIds.contains(d.id)),
    ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (allDots.isEmpty) return null;
    return RecordingSession(
      dayLogId: dayLog?.id ?? 'local_${now.year}_${now.month}_${now.day}',
      dots: allDots,
    );
  }

  /// dot 찍기 — 위치 수집 → 역지오코딩 → (사진 업로드) → 저장.
  /// 반환값: 저장된 Dot (실패 시 null). 오늘 첫 dot이면 [isFirst] = true.
  /// place 거리 검증 임계값 — 검색 장소와 실제 위치 차이가 이 값(m)을 넘으면
  /// `PlaceTooFarException` throw. caller 가 사용자에게 확인 받고 재호출 가능.
  static const double placeMaxDistanceM = 200.0;

  Future<({Dot? dot, bool isFirst})> captureDot({
    String? memo,
    String? emotion,
    String? photoLocalPath,
    String? placeId, // B8 — 사용자가 검색해서 선택한 place_id
    double? placeLat, // 거리 검증용 (선택). null 이면 검증 skip.
    double? placeLng,
    /// 호출자가 *완전한* Place 객체를 갖고 있을 때 (예: 체크인) 명시 전달.
    /// dot 에 inline 으로 들어가 dot detail 의 장소 카드 즉시 표시.
    /// BE 응답에 place 가 채워지지 않거나 fetch 가 지연돼도 카드가 안 사라짐.
    Place? placeOverride,
    bool overrideDistanceCheck = false, // confirm 후 재호출 시 true
    List<String> tags = const [],
  }) async {
    final session = state.valueOrNull;
    final isFirst = session == null;

    if (session != null) {
      state = AsyncValue.data(session.copyWith(isCapturingLocation: true));
    }

    try {
      final locationService = ref.read(locationServiceProvider);
      final geocodingService = ref.read(geocodingServiceProvider);
      final repo = ref.read(dotRepositoryProvider);
      // BE UUID(currentDottieUser) 우선, 미로딩 시 Firebase UID 폴백.
      final userId = ref.read(currentDottieUserProvider).valueOrNull?.uid ??
          ref.read(currentUserProvider)?.uid;
      if (userId == null) throw StateError('dot 기록에는 로그인이 필요합니다.');

      final position = await locationService.getCurrentPosition();
      debugPrint(
          '[captureDot] position=${position.latitude},${position.longitude} placeId=$placeId');

      // B8 거리 검증 — 검색 장소가 현재 위치에서 너무 멀면 PlaceTooFarException
      if (placeId != null &&
          placeLat != null &&
          placeLng != null &&
          !overrideDistanceCheck) {
        final distM = LocationUtils.distanceM(
          position.latitude,
          position.longitude,
          placeLat,
          placeLng,
        );
        debugPrint('[captureDot] place distance=${distM.toStringAsFixed(1)}m');
        if (distM > placeMaxDistanceM) {
          throw PlaceTooFarException(
              distanceM: distM, thresholdM: placeMaxDistanceM);
        }
      }

      // dot 좌표 결정:
      //  - 사용자가 장소 검색해서 선택한 경우 → **place 좌표 사용** (인증 의도).
      //    실제 GPS 위치는 거리 검증에만 쓰이고 dot 자체는 그 장소에 찍힘.
      //  - 미선택 시 → 현재 GPS 좌표.
      //
      // 친구와 동선 공유 시 "여기 갔다왔어" 가 명확해짐 (GPS 노이즈 제거).
      final hasPlace =
          placeId != null && placeLat != null && placeLng != null;
      final dotLat = hasPlace ? placeLat : position.latitude;
      final dotLng = hasPlace ? placeLng : position.longitude;

      // 역지오코딩은 사용자 GPS 위치 기준 (dot 좌표 != GPS 좌표 일 수 있음).
      // place 가 있으면 BE 가 place.address 를 시트에 별도로 보여줌.
      final geocoding = await geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      String? uploadedPhotoUrl;
      if (photoLocalPath != null) {
        uploadedPhotoUrl = await repo.uploadPhoto(photoLocalPath);
      }

      final now = DateTime.now();
      // 오프라인 시 사용할 temp dayLogId
      final tempDayLogId =
          session?.dayLogId ?? 'local_${now.millisecondsSinceEpoch}';

      final dot = Dot(
        id: '${now.millisecondsSinceEpoch}',
        latitude: dotLat,
        longitude: dotLng,
        timestamp: now,
        placeName: geocoding?.placeName,
        placeCategory: geocoding?.placeCategory,
        memo: memo,
        emotion: emotion,
        photoUrl: uploadedPhotoUrl,
        dayLogId: tempDayLogId,
        placeId: placeId,
        // BE 가 응답에 place 객체를 안 채워주거나 채우는 timing 이 늦어도
        // dot_content_block 의 장소 카드가 즉시 표시되게 client-side 에서 inline.
        place: placeOverride,
        tags: tags,
      );

      final saveResult = await repo.saveDot(dot, userId: userId);
      debugPrint(
          '[captureDot] saveDot returned dayLogId=${saveResult.dayLogId} '
          'serverDotId=${saveResult.serverDotId} tempDayLogId=$tempDayLogId');
      final effectiveDayLogId = saveResult.dayLogId ?? tempDayLogId;
      // 온라인 성공 시 server UUID 로 일원화 — 시트 polling / 검색 / refresh 의
      // dot.id 매칭이 client timestamp 와 server UUID 차이로 실패하지 않도록.
      // 오프라인이면 client 임시 id 그대로 (다음 batch sync 시 BE 가 server id 발급).
      final savedDot = dot.copyWith(
        id: saveResult.serverDotId ?? dot.id,
        dayLogId: effectiveDayLogId,
      );
      debugPrint(
          '[captureDot] savedDot id=${savedDot.id} placeId=${savedDot.placeId}');

      final current = state.valueOrNull;
      if (current == null) {
        state = AsyncValue.data(RecordingSession(
          dayLogId: effectiveDayLogId,
          dots: [savedDot],
        ));
      } else {
        state = AsyncValue.data(current.copyWith(
          dayLogId: effectiveDayLogId,
          dots: [...current.dots, savedDot],
          isCapturingLocation: false,
          error: null,
        ));
      }

      // BE 응답에서 채워지는 정보 (사진 variant + place 객체) 가 client-side
      // dot 에는 없음. uploadDot 가 응답에서 id/dayLogId 만 추출하기 때문.
      // 일정 간격으로 BE today daylog 를 refetch → state.dots 통째 교체 →
      // 사진 variant + place 객체 둘 다 채워진 dot 으로 갱신. fire-and-forget.
      //
      // 트리거: 사진이 있거나 (variant 워커 대기) place_id 가 있을 때
      // (체크인 dot 처럼 reverse geocoding 결과만 들어간 채로 노출되면
      // dot_content_block 의 place 카드 ("강남역") 가 안 보이는 문제).
      final needsRefresh =
          (savedDot.photoUrl != null && savedDot.photoUrl!.isNotEmpty) ||
              savedDot.placeId != null;
      if (needsRefresh) {
        unawaited(_pollPhotoVariants());
      }

      return (dot: savedDot, isFirst: isFirst);
    } on LocationException {
      // 위치 권한 거부 / 서비스 OFF / 타임아웃 — 호출자가 _showLocationError 로
      // 사용자에게 설정 안내를 제공할 수 있도록 rethrow.
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(isCapturingLocation: false));
      }
      rethrow;
    } on PlaceTooFarException {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(isCapturingLocation: false));
      }
      // 호출자가 사용자에게 확인 받고 재호출 가능하도록 rethrow
      rethrow;
    } on DotUploadException {
      // BE 4xx 비즈니스 에러 — 호출자가 사용자에게 토스트로 알릴 수 있도록 전파.
      // 로컬 저장도 하지 않음 (잘못된 데이터를 로컬에 남기면 batch sync 시 또 거절됨).
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(isCapturingLocation: false));
      }
      rethrow;
    } catch (e, st) {
      debugPrint('[captureDot] error: $e\n$st');
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(
            current.copyWith(isCapturingLocation: false, error: e.toString()));
      }
      return (dot: null, isFirst: false);
    }
  }

  /// 사진 첨부 dot 의 variant 가 BE 에서 채워졌는지 일정 간격으로 확인 → state 갱신.
  ///
  /// BE 정책: variant 워커가 비동기로 thumb/preview 생성 후 photo_url 응답에서
  /// 제거. dot 찍은 직후엔 응답에 thumb/preview 가 모두 null 일 수 있음. 사용자가
  /// today_map_screen 또는 dot 시트에 머물러 있으면 자동으로 채워진 dot 으로 갱신.
  ///
  /// - 5초 / 10초 두 번 시도 (워커 처리 시간 ~수초)
  /// - 매 시도에서 BE 의 today daylog 를 다시 fetch → state.dots 통째 교체
  /// - notifier 가 dispose 되면 즉시 중단
  Future<void> _pollPhotoVariants() async {
    // 첫 시도는 빠르게 (1초) — place_id 만 보강 필요한 케이스(체크인 dot)
    // 는 BE 가 즉시 응답에 채워줌. 두 번째는 사진 variant 워커 대기 (5초).
    const intervals = [Duration(seconds: 1), Duration(seconds: 5)];
    for (final delay in intervals) {
      await Future<void>.delayed(delay);
      if (_disposed) return;
      try {
        final fresh =
            await ref.read(dotRepositoryProvider).restoreTodayFromServer();
        if (_disposed || fresh == null) continue;
        // BE 응답으로 state 교체 — server-side dot id 로 일원화.
        // 단 *기존 dot 에 client-side 가 채운 place 객체가 있는데* BE 응답에
        // 같은 dot 의 place 가 null 이면 — *기존 것 유지* (체크인 dot 처럼
        // BE 가 응답에 place 안 넣어주는 케이스 보호).
        final existingDots = state.valueOrNull?.dots ?? const <Dot>[];
        final merged = fresh.dots.map((freshDot) {
          if (freshDot.place != null) return freshDot;
          // 같은 dot 인 기존 state 의 항목 찾기 — id 또는 placeId+timestamp 매칭.
          // server 가 client id → server uuid 로 발급해도 placeId 와 timestamp
          // 거의 동일하므로 fallback 매칭 활용.
          for (final old in existingDots) {
            final sameId = old.id == freshDot.id;
            final samePlace = old.placeId != null &&
                old.placeId == freshDot.placeId &&
                old.timestamp
                        .difference(freshDot.timestamp)
                        .inSeconds
                        .abs() <
                    60;
            if ((sameId || samePlace) && old.place != null) {
              return freshDot.copyWith(place: old.place);
            }
          }
          return freshDot;
        }).toList();

        state = AsyncValue.data(RecordingSession(
          dayLogId: fresh.id,
          dots: merged,
        ));
        // feed/timeline 카드도 새 thumb/preview URL 받게 override store 갱신.
        // sheet 가 이미 닫혀 다른 화면으로 이동했어도 카드가 즉시 사진 표시.
        final overrides = ref.read(dotPhotoOverridesProvider.notifier);
        for (final d in fresh.dots) {
          if (!d.hasPhotoData) continue;
          if (d.photoThumbUrl == null && d.photoPreviewUrl == null) continue;
          overrides.set(
            d.id,
            thumbUrl: d.photoThumbUrl,
            previewUrl: d.photoPreviewUrl,
          );
        }
        // 모든 사진 dot 이 thumb/preview 둘 중 하나는 채워졌으면 polling 종료.
        // (photoUrl 은 BE 응답에 안 옴 → 추적 불가. 보수적으로 thumb/preview
        //  채워진 게 하나라도 늘었으면 아직 변환 중인 dot 이 있을 수도 있는데
        //  최대 2번 polling 후 자연 종료.)
        final allReady = fresh.dots.every(
          (d) =>
              (d.photoThumbUrl != null && d.photoThumbUrl!.isNotEmpty) ||
              (d.photoPreviewUrl != null && d.photoPreviewUrl!.isNotEmpty) ||
              !d.hasPhotoData, // 사진 없는 dot 은 OK
        );
        if (allReady) return;
      } catch (e) {
        debugPrint('[captureDot] photo variant polling error: $e');
      }
    }
  }
}

/// 검색한 장소가 현재 위치에서 너무 멀어 등록 차단됨.
/// caller 는 사용자 confirm 받은 뒤 `overrideDistanceCheck: true` 로 재호출 가능.
class PlaceTooFarException implements Exception {
  PlaceTooFarException({required this.distanceM, required this.thresholdM});
  final double distanceM;
  final double thresholdM;

  @override
  String toString() =>
      '선택한 장소가 현재 위치에서 ${distanceM.toStringAsFixed(0)}m 떨어져 있어요 '
      '(허용 ${thresholdM.toStringAsFixed(0)}m).';
}

// 오늘 DayLog — 서버 우선, 없으면 로컬 폴백
@riverpod
Future<DayLog?> todayDayLog(Ref ref) async {
  final repo = ref.watch(dotRepositoryProvider);
  final serverLog = await repo.restoreTodayFromServer();
  if (serverLog != null) return serverLog;
  // BE UUID 가 준비된 다음에만 로컬 폴백 — Firebase UID 로 조회하면 0 결과.
  final dottie = await ref.watch(currentDottieUserProvider.future);
  if (dottie == null) return null;
  return repo.getDayLogByDate(DateTime.now(), dottie.uid);
}

// 전체 DayLog 목록 (타임라인용)
@riverpod
Future<List<DayLog>> allDayLogs(Ref ref) async {
  final dottie = await ref.watch(currentDottieUserProvider.future);
  if (dottie == null) return const [];
  return ref.watch(dotRepositoryProvider).getAllDayLogs(dottie.uid);
}
