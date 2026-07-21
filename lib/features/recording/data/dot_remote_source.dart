import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/utils/image_compress.dart';
import '../domain/dot_model.dart';
import '../../timeline/domain/day_log_model.dart';
import 'dot_api_parser.dart';

part 'dot_remote_source.g.dart';

class DotRemoteSource {
  DotRemoteSource(this._dio);
  final Dio _dio;

  Future<String?> uploadPhoto(String filePath) async {
    try {
      // 업로드 전 압축 — 최대 1080px / JPEG 82%. 실패 시 원본 사용.
      final uploadPath = await ImageCompress.forUpload(filePath);
      final file = File(uploadPath);
      final fileSize = await file.length();
      final contentType = _mimeType(uploadPath);

      // Step 1: presigned upload URL 요청
      final res = await _dio.post(
        ApiEndpoints.mediaUpload,
        data: {'content_type': contentType, 'file_size': fileSize},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final uploadUrl = res.data['data']['upload_url'] as String?;
      final publicUrl = res.data['data']['public_url'] as String?;
      if (uploadUrl == null || publicUrl == null) return null;

      // Step 2: presigned URL에 파일 바이너리 직접 PUT
      // - 별도 Dio 인스턴스 사용 → 인증 인터셉터/기본 헤더 미포함
      // - Stream 대신 Uint8List 직접 전송 → Content-Length 보장
      final bytes = await file.readAsBytes(); // 압축된 파일 바이트
      final putDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final putRes = await putDio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          contentType: contentType,
          headers: {'Content-Length': bytes.length},
        ),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 204) {
        debugPrint('[Media] presigned PUT failed: ${putRes.statusCode}');
        _deleteTempFile(uploadPath, filePath);
        return null;
      }
      assert(() {
        debugPrint('[Media] PUT success → public_url=$publicUrl');
        return true;
      }());

      // 압축으로 생성된 임시 파일 삭제 (원본은 유지).
      _deleteTempFile(uploadPath, filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('[Media] uploadPhoto error: $e');
      return null;
    }
  }

  /// 압축 temp 파일만 삭제. 원본([originalPath])과 같은 경로면 건드리지 않음.
  static void _deleteTempFile(String uploadPath, String originalPath) {
    if (uploadPath == originalPath) return;
    try {
      File(uploadPath).deleteSync();
    } catch (_) {
      // 삭제 실패는 무시 — OS가 temp 디렉토리를 자체적으로 정리
    }
  }

  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  /// dot 업로드 — date 기반으로 서버가 daylog 자동 생성/조회.
  /// 성공 시 (dayLogId, dotId) 반환. 네트워크 실패(오프라인) 시 (null, null) —
  /// 호출자가 로컬 폴백. **서버가 응답한 4xx 비즈니스 에러는 [DotUploadException]
  /// 으로 throw** — 사용자에게 안내해야 함 (예: `INVALID_TAG_FORMAT`).
  Future<({String? dayLogId, String? dotId})> uploadDot(Dot dot) async {
    try {
      final local = dot.timestamp.toLocal();
      final date =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      // photo_url 도 dot 생성과 한 번에 보냄 (배치 endpoint 와 동일 패턴).
      // 별도 PATCH /v1/dots/:id/photo 호출 없이 BE 가 dot 저장 + variant 생성을
      // 함께 트리거. photoUrl 이 null 이면 photo 없는 dot.
      final res = await _dio.post(ApiEndpoints.dots, data: {
        'date': date,
        'latitude': dot.latitude,
        'longitude': dot.longitude,
        'timestamp': dot.timestamp.toUtc().toIso8601String(),
        'place_name': dot.placeName,
        'place_category': dot.placeCategory,
        'memo': dot.memo,
        'emotion': dot.emotion,
        'tags': dot.tags,
        if (dot.placeId != null) 'place_id': dot.placeId, // B8
        if (dot.photoUrl != null && dot.photoUrl!.isNotEmpty)
          'photo_url': dot.photoUrl,
      });
      // 응답 body 에 위/경도·장소명·메모가 담겨 있어 release 로그로 새면 안 됨.
      assert(() {
        debugPrint('[uploadDot] status=${res.statusCode} raw=${res.data}');
        return true;
      }());
      // 응답 형태 호환 — `{data:{...}}` 또는 평면 `{...}` 둘 다 처리
      final body = res.data;
      Map<String, dynamic>? data;
      if (body is Map<String, dynamic>) {
        if (body['data'] is Map<String, dynamic>) {
          data = body['data'] as Map<String, dynamic>;
        } else {
          data = body;
        }
      }
      final dayLogId = data?['day_log_id'] as String?;
      final dotId = data?['id'] as String?;
      assert(() {
        debugPrint('[uploadDot] parsed dayLogId=$dayLogId dotId=$dotId');
        return true;
      }());
      return (dayLogId: dayLogId, dotId: dotId);
    } on DioException catch (e, st) {
      // 4xx — 서버가 응답한 비즈니스 에러: typed exception 으로 변환해 caller 에 전파.
      // FE 가 사전 정규화하므로 `INVALID_TAG_FORMAT` 등은 거의 발생하지 않지만,
      // 발생하면 사용자에게 명확히 알려야 함 (조용히 로컬 폴백하면 안 됨).
      if (e.response != null) {
        final code = _extractErrorCode(e);
        debugPrint('[uploadDot] 4xx code=$code: $e');
        throw DotUploadException(
          code: code,
          message: _extractErrorMessage(e),
          statusCode: e.response?.statusCode,
          retryAfterSeconds: _extractRetryAfter(e),
        );
      }
      // 네트워크 오류(타임아웃 등) → 오프라인 폴백.
      debugPrint('[uploadDot] network error → offline fallback: $e\n$st');
      return (dayLogId: null, dotId: null);
    } catch (e, st) {
      debugPrint('[uploadDot] unexpected: $e\n$st');
      return (dayLogId: null, dotId: null);
    }
  }

  static String? _extractErrorCode(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map<String, dynamic>) return err['code'] as String?;
      return body['code'] as String?;
    }
    return null;
  }

  static String? _extractErrorMessage(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map<String, dynamic>) return err['message'] as String?;
      return body['message'] as String?;
    }
    return null;
  }

  /// `error.retry_after_seconds` (RATE_LIMITED 응답 한정). 1~60 범위.
  /// 응답 envelope 변형 (`error.retry_after_seconds` / 평면) 모두 지원.
  static int? _extractRetryAfter(DioException e) {
    final body = e.response?.data;
    if (body is! Map) return null;
    final err = body['error'];
    final src = err is Map ? err : body;
    final v = src['retry_after_seconds'];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  /// PATCH /dots/{id}/photo — 업로드된 사진 URL을 dot에 저장
  Future<void> patchDotPhoto(String dotId, String photoUrl) async {
    try {
      await _dio.patch(
        ApiEndpoints.dotPhoto(dotId),
        data: {'photo_url': photoUrl},
      );
    } catch (e) {
      debugPrint('[Media] patchDotPhoto error: $e');
    }
  }

  /// DELETE /v1/dots/:id — dot 단건 삭제.
  /// BE 가 dot + dot_comments + dot_tags 를 CASCADE 처리하고
  /// notifications.dot_id 는 NULL 로 세팅 (알림 row 자체 유지).
  ///
  /// 반환값: 서버가 삭제를 인지했는지(true) / 네트워크 오류로 알 수 없음(false).
  /// 4xx 는 [DotDeleteException] 으로 변환해 caller 에 전파.
  ///   - 404: 이미 삭제됨 — caller 가 로컬도 정리 (멱등)
  ///   - 403: 본인 소유가 아님 — UI 안내
  ///   - 400: UUID 포맷 오류 (클라 버그)
  Future<bool> deleteDot(String id) async {
    try {
      await _dio.delete(ApiEndpoints.dotById(id));
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        throw DotDeleteException(
          code: _extractErrorCode(e),
          message: _extractErrorMessage(e),
          statusCode: e.response?.statusCode,
        );
      }
      debugPrint('[deleteDot] network error: $e');
      return false;
    }
  }

  /// POST /v1/dots/:id/hide — 특정 룸에서 dot 숨김.
  /// BE 가 자동으로 shared-map / cumulative-dots 응답에서 필터링.
  /// 4xx 는 [HideDotException] 으로 변환.
  Future<void> hideDotInRoom(String dotId, String roomId) async {
    try {
      await _dio.post(
        ApiEndpoints.dotHide(dotId),
        data: {'room_id': roomId},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw HideDotException(
          code: _extractErrorCode(e),
          message: _extractErrorMessage(e),
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  /// DELETE /v1/dots/:id/hide/:roomId — 룸별 숨김 해제. 멱등.
  Future<void> unhideDotInRoom(String dotId, String roomId) async {
    try {
      await _dio.delete(ApiEndpoints.dotUnhide(dotId, roomId));
    } on DioException catch (e) {
      if (e.response != null) {
        throw HideDotException(
          code: _extractErrorCode(e),
          message: _extractErrorMessage(e),
          statusCode: e.response?.statusCode,
        );
      }
      rethrow;
    }
  }

  /// GET /v1/rooms/:id/hidden-dots-by-me — 본인이 그 룸에서 숨긴 dot 목록.
  /// created_at DESC 정렬. 응답 dot 객체는 일반 dot 응답과 동일 형태.
  Future<List<Dot>> getHiddenDotsByMe(String roomId) async {
    try {
      final res = await _dio.get(ApiEndpoints.roomHiddenDotsByMe(roomId));
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final rawDots = (data['dots'] as List?) ?? const [];
      return rawDots
          .map((d) => dotFromApi(d as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return const []; // 오프라인 → 빈 목록
    }
  }

  /// DELETE /daylogs/:id — daylog + 연결 dots 서버에서 삭제
  /// 오프라인이면 false 반환, 서버 에러(4xx/5xx)면 rethrow
  Future<bool> deleteDayLog(String id) async {
    try {
      await _dio.delete(ApiEndpoints.daylogById(id));
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return false;
    }
  }

  /// GET /daylogs/today?date=YYYY-MM-DD — 로컬 날짜 기준 오늘 세션 복원
  Future<DayLog?> getTodayDayLog(String localDate) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.daylogsToday,
        queryParameters: {'date': localDate},
      );
      final data = res.data['data'];
      if (data == null) return null;
      return _dayLogFromApi(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GET /v1/daylogs — 사용자의 전체 daylog 목록 (dots 포함).
  /// 네트워크 실패 시 null 반환 (호출부에서 로컬 폴백).
  Future<List<DayLog>?> getAllDayLogs() async {
    try {
      final res = await _dio.get(ApiEndpoints.daylogs);
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => _dayLogFromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[DotRemote] getAllDayLogs failed: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[DotRemote] getAllDayLogs error: ${e.runtimeType}');
      return null;
    }
  }

  static DayLog _dayLogFromApi(Map<String, dynamic> d) {
    final rawDots = d['dots'] as List? ?? [];
    final dots =
        rawDots.map((e) => dotFromApi(e as Map<String, dynamic>)).toList();
    return DayLog(
      id: d['id'] as String,
      userId: d['user_id'] as String,
      date: DateTime.parse(d['date'] as String),
      startedAt: DateTime.parse(d['started_at'] as String),
      endedAt: d['ended_at'] != null
          ? DateTime.parse(d['ended_at'] as String)
          : null,
      isRecording: d['is_recording'] as bool? ?? false,
      dots: dots,
      synced: true,
    );
  }

  /// GET /daylogs/:id — dots 포함한 DayLog 조회
  Future<List<Dot>?> getDayLogDots(String dayLogId) async {
    try {
      final res = await _dio.get(ApiEndpoints.daylogById(dayLogId));
      final data = res.data['data'] as Map<String, dynamic>;
      final rawDots = data['dots'] as List? ?? [];
      return rawDots
          .map((d) => dotFromApi(d as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ── 태그 검색 / 자동완성 / 인기 (B16) ──────────────────

  /// `GET /v1/dots/search` — 태그 매칭 dot 페이지.
  /// 서버 응답 dot 객체는 일반 daylog dot 응답과 동일 형태 + 검색 응답 한정으로
  /// owner 메타(user_id/nickname/color/room_id) 가 함께 옴. `dotFromApi` 로
  /// dot 만 만들고 owner 메타는 별도 record 로 wrap.
  /// 4xx 는 [DioException] re-throw — 호출자가 코드별 처리.
  Future<({List<TagSearchHit> results, String? nextCursor})> searchDotsByTags({
    required List<String> tags,
    String match = 'all',
    DateTime? from,
    DateTime? to,
    int limit = 30,
    String? cursor,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.dotsSearch,
      queryParameters: {
        'tags': tags.join(','),
        'match': match,
        if (from != null) 'from': _formatDate(from),
        if (to != null) 'to': _formatDate(to),
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final body = res.data;
    final data = _unwrapDataMap(body);
    final rawDots = data['dots'];
    // 각 dot 에 소유자 메타 추가 — 본인/타인 분기 (search scope 확장: 본인 +
    // 본인이 속한 룸 멤버 dot). BE 가 user_id / user_nickname / user_color_hex /
    // room_id 를 같이 보냄.
    final results = (rawDots is List)
        ? rawDots
            .whereType<Map>()
            .map((d) => _searchResultFromApi(d.cast<String, dynamic>()))
            .toList(growable: false)
        : const <TagSearchHit>[];
    final cursor0 = data['next_cursor'];
    return (
      results: results,
      nextCursor: cursor0 is String ? cursor0 : null,
    );
  }

  static TagSearchHit _searchResultFromApi(Map<String, dynamic> d) {
    // 디버그 빌드에서만 raw 응답 일부 출력 — 본인/타인 분기 / 중복 검증용.
    // BE 가 user_id/room_id 를 정상적으로 보내는지 확인.
    assert(() {
      debugPrint(
          '[TagSearch.hit] dot_id=${d['id']} user_id=${d['user_id']} '
          'nickname=${d['user_nickname']} room_id=${d['room_id']}');
      return true;
    }());
    return (
      dot: dotFromApi(d),
      userId: d['user_id'] as String? ?? '',
      userNickname: d['user_nickname'] as String? ?? '',
      userColorHex: d['user_color_hex'] as String?,
      roomId: d['room_id'] as String?,
    );
  }

  /// `GET /v1/dots/cumulative` — 본인 전체 dot 페이지.
  /// timestamp DESC, cursor pagination. search 응답과 달리 owner 메타 없음
  /// (전부 본인). 4xx 는 [DioException] re-throw.
  Future<({List<Dot> dots, String? nextCursor})> getCumulativeDots({
    DateTime? from,
    DateTime? to,
    int limit = 100,
    String? cursor,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.dotsCumulative,
      queryParameters: {
        if (from != null) 'from': _formatDate(from),
        if (to != null) 'to': _formatDate(to),
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final data = _unwrapDataMap(res.data);
    final rawDots = data['dots'];
    final dots = (rawDots is List)
        ? rawDots
            .whereType<Map>()
            .map((d) => dotFromApi(d.cast<String, dynamic>()))
            .toList(growable: false)
        : const <Dot>[];
    final cursor0 = data['next_cursor'];
    return (
      dots: dots,
      nextCursor: cursor0 is String ? cursor0 : null,
    );
  }

  /// `GET /v1/dots/tags?prefix=...` — 자동완성 후보.
  Future<List<({String tag, int count})>> autocompleteTags(
    String prefix, {
    int limit = 10,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.dotsTags,
      queryParameters: {
        'prefix': prefix,
        'limit': limit,
      },
    );
    return _decodeTagCountList(res.data);
  }

  /// `GET /v1/dots/tags/popular` — 인기 태그 (검색 첫 진입 cloud).
  ///
  /// [roomId] 미지정: 본인 모든 dot 의 태그 집계 (기존 동작).
  /// [roomId] 지정: 그 방에 공유된 dot (멤버 dot + 본인 공유 dot, hidden 제외)
  /// 의 태그 집계. viewer 가 그 방 멤버가 아니면 BE 가 `403 FORBIDDEN`.
  Future<List<({String tag, int count})>> popularTags({
    String? roomId,
    DateTime? from,
    DateTime? to,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.dotsTagsPopular,
      queryParameters: {
        if (roomId != null) 'room_id': roomId,
        if (from != null) 'from': _formatDate(from),
        if (to != null) 'to': _formatDate(to),
        'limit': limit,
      },
    );
    return _decodeTagCountList(res.data);
  }

  /// 응답 envelope 에서 List 를 안전하게 추출. `data` key 가 List 일 수도, body 자체가
  /// List 일 수도 있어 둘 다 처리. 형태가 예상과 다르면 빈 리스트 반환.
  static List<({String tag, int count})> _decodeTagCountList(dynamic body) {
    final List raw;
    if (body is Map && body['data'] is List) {
      raw = body['data'] as List;
    } else if (body is List) {
      raw = body;
    } else {
      return const [];
    }
    final out = <({String tag, int count})>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final tag = e['tag'];
      if (tag is! String || tag.isEmpty) continue;
      final count = e['count'];
      out.add((
        tag: tag,
        count: count is num ? count.toInt() : 0,
      ));
    }
    return out;
  }

  /// `data` envelope 또는 평면 body 모두 Map 으로 안전 추출.
  static Map<String, dynamic> _unwrapDataMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      final inner = body['data'];
      if (inner is Map<String, dynamic>) return inner;
      return body;
    }
    if (body is Map) {
      return body.cast<String, dynamic>();
    }
    return const {};
  }

  static String _formatDate(DateTime d) {
    final local = d.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  /// dot 배치 업로드 — 날짜별로 그룹화해서 전송.
  ///
  /// BE 응답 구조:
  /// ```
  /// { "data": { "synced": [...], "failed": [{ "client_id", "reason" }] } }
  /// ```
  /// failed 는 정책 위반(예: 태그 10개 초과) — 호출자가 받아 markSynced 처리해
  /// 무한 retry 를 막아야 함.
  Future<BatchSyncResult> batchSyncDots(List<Dot> dots) async {
    if (dots.isEmpty) return const BatchSyncResult.empty();
    // timestamp 기준으로 날짜별 그룹화 (day_log_id 대신 date 사용)
    final grouped = <String, List<Dot>>{};
    for (final d in dots) {
      final local = d.timestamp.toLocal();
      final dateKey =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      (grouped[dateKey] ??= []).add(d);
    }
    final synced = <String>{};
    final clientToServer = <String, String>{};
    final failed = <BatchSyncFailure>[];
    for (final entry in grouped.entries) {
      // 이번 batch 가 실제로 보낸 client_id set — BE 응답이 다른 id 를 echo
      // 하더라도 해당 id 가 우리가 안 보낸 거면 무시 (defense-in-depth).
      final sentIds = entry.value.map((d) => d.id).toSet();
      try {
        final res = await _dio.post(
          ApiEndpoints.dotsBatch,
          data: {
            'date': entry.key,
            'dots': entry.value
                .map((d) => {
                      'client_id': d.id,
                      'latitude': d.latitude,
                      'longitude': d.longitude,
                      'timestamp': d.timestamp.toUtc().toIso8601String(),
                      'place_name': d.placeName,
                      'place_category': d.placeCategory,
                      'memo': d.memo,
                      'emotion': d.emotion,
                      'photo_url': d.photoUrl,
                      'tags': d.tags,
                      if (d.placeId != null) 'place_id': d.placeId, // B8
                    })
                .toList(),
          },
        );
        _accumulateBatchResult(
          res.data,
          synced: synced,
          clientToServer: clientToServer,
          failed: failed,
          sentIds: sentIds,
        );
      } on DioException catch (e) {
        // 네트워크/서버 오류 — 다음 sync 주기에 다시 시도하도록 그대로 둠.
        debugPrint('[batchSync] date=${entry.key} dio error: ${e.message}');
      } catch (e, st) {
        debugPrint('[batchSync] date=${entry.key} unexpected: $e\n$st');
      }
    }
    return BatchSyncResult(
      syncedClientIds: synced,
      clientToServer: clientToServer,
      failed: failed,
    );
  }

  static void _accumulateBatchResult(
    dynamic body, {
    required Set<String> synced,
    required Map<String, String> clientToServer,
    required List<BatchSyncFailure> failed,
    required Set<String> sentIds,
  }) {
    if (body is! Map) return;
    final inner = body['data'];
    final data = inner is Map ? inner : body;
    final rawSynced = data['synced'];
    if (rawSynced is List) {
      for (final e in rawSynced) {
        String? cid;
        String? sid;
        if (e is Map && e['client_id'] is String) {
          cid = e['client_id'] as String;
          // BE 가 발급한 server dot id — 로컬 dot row remap 및
          // todo 체크인(check_in_dot_id) 서버 반영에 필요.
          if (e['server_id'] is String) sid = e['server_id'] as String;
        } else if (e is String) {
          cid = e;
        }
        if (cid == null) continue;
        // BE 가 echo 한 client_id 가 우리가 보낸 set 에 있어야만 인정.
        if (!sentIds.contains(cid)) {
          debugPrint(
              '[batchSync] BE echoed unknown synced client_id=$cid — ignored');
          continue;
        }
        synced.add(cid);
        if (sid != null && sid.isNotEmpty) clientToServer[cid] = sid;
      }
    }
    final rawFailed = data['failed'];
    if (rawFailed is List) {
      for (final e in rawFailed) {
        if (e is! Map) continue;
        final cid = e['client_id'];
        if (cid is! String) continue;
        if (!sentIds.contains(cid)) {
          debugPrint(
              '[batchSync] BE echoed unknown failed client_id=$cid — ignored');
          continue;
        }
        final reason = e['reason'];
        // retry_after_seconds 는 reason="rate_limited" 일 때만 BE 가 포함.
        final retry = e['retry_after_seconds'];
        failed.add(BatchSyncFailure(
          clientId: cid,
          reason: reason is String ? reason : 'unknown',
          retryAfterSeconds: retry is num ? retry.toInt() : null,
        ));
      }
    }
  }
}

/// `/dots/batch` 결과 — 호출자가 synced 만 markSynced, failed 는 별도 정책 적용.
class BatchSyncResult {
  const BatchSyncResult({
    required this.syncedClientIds,
    this.clientToServer = const {},
    required this.failed,
  });
  const BatchSyncResult.empty()
      : syncedClientIds = const {},
        clientToServer = const {},
        failed = const [];
  final Set<String> syncedClientIds;

  /// client_id → BE 발급 server dot id. 로컬 dot row 를 server id 로 remap
  /// 해 체크인 등 dot 참조가 서버와 일치하도록 한다.
  final Map<String, String> clientToServer;
  final List<BatchSyncFailure> failed;

  bool get isEmpty => syncedClientIds.isEmpty && failed.isEmpty;
}

class BatchSyncFailure {
  const BatchSyncFailure({
    required this.clientId,
    required this.reason,
    this.retryAfterSeconds,
  });
  final String clientId;
  final String reason;

  /// `reason == "rate_limited"` 일 때만 BE 가 채워주는 1~60 초 값.
  /// 그 외 reason 은 null. caller 는 nullable 로 처리.
  final int? retryAfterSeconds;

  bool get isRateLimited => reason == 'rate_limited';
}

/// 태그 검색 응답의 한 항목 — dot + 소유자 메타.
/// remote 레이어 record (data layer 노출). 상위에서 domain `TagSearchResult` 로 wrap.
typedef TagSearchHit = ({
  Dot dot,
  String userId,
  String userNickname,
  String? userColorHex,
  String? roomId,
});

@riverpod
DotRemoteSource dotRemoteSource(Ref ref) =>
    DotRemoteSource(ApiClient.instance);

/// BE 가 4xx 로 거부한 dot 업로드 에러.
/// 화면 단에서 [code] 별 메시지 분기 (예: `INVALID_TAG_FORMAT`, `TAGS_TOO_MANY`,
/// `RATE_LIMITED`). [code] == `RATE_LIMITED` 일 때 [retryAfterSeconds] 가 1~60.
class DotUploadException implements Exception {
  const DotUploadException({
    this.code,
    this.message,
    this.statusCode,
    this.retryAfterSeconds,
  });
  final String? code;
  final String? message;
  final int? statusCode;

  /// RATE_LIMITED 응답에 포함된 다음 시도 가능 시점 (초). 그 외엔 null.
  final int? retryAfterSeconds;

  bool get isInvalidTagFormat => code == 'INVALID_TAG_FORMAT';
  bool get isTagsTooMany => code == 'TAGS_TOO_MANY';
  bool get isRateLimited => code == 'RATE_LIMITED';

  @override
  String toString() =>
      'DotUploadException(status=$statusCode, code=$code, msg=$message, retry=$retryAfterSeconds)';
}

/// BE 가 4xx 로 거부한 dot 삭제 에러.
/// caller 가 [statusCode] / [code] 별로 사용자 안내 분기:
///   - 403 / FORBIDDEN: "본인 기록만 삭제할 수 있습니다"
///   - 404 / DOT_NOT_FOUND: 이미 삭제 — 로컬도 정리하고 무시
///   - 400 / INVALID_ID: 클라 버그 (사용자에 노출 X, 로깅만)
class DotDeleteException implements Exception {
  const DotDeleteException({this.code, this.message, this.statusCode});
  final String? code;
  final String? message;
  final int? statusCode;

  bool get isNotFound =>
      statusCode == 404 || code == 'DOT_NOT_FOUND';
  bool get isForbidden =>
      statusCode == 403 || code == 'FORBIDDEN';

  @override
  String toString() =>
      'DotDeleteException(status=$statusCode, code=$code, msg=$message)';
}

/// dot 룸별 숨김/해제 4xx 에러.
/// caller 가 [code] / [statusCode] 로 분기:
///   - 400 / DAY_LOG_NOT_SHARED: 그 룸에 day_log 가 안 공유돼 있음 (숨길 게 없음)
///   - 403 / FORBIDDEN: 룸 멤버 아님 또는 본인 dot 아님
///   - 404 / DOT_NOT_FOUND: dot 자체가 없음
class HideDotException implements Exception {
  const HideDotException({this.code, this.message, this.statusCode});
  final String? code;
  final String? message;
  final int? statusCode;

  bool get isForbidden =>
      statusCode == 403 || code == 'FORBIDDEN';
  bool get isNotShared => code == 'DAY_LOG_NOT_SHARED';

  @override
  String toString() {
    if (isForbidden) return '본인 기록만 숨길 수 있어요.';
    if (isNotShared) return '이 방에 공유되지 않은 기록이에요.';
    return '숨김 처리에 실패했어요.';
  }
}
