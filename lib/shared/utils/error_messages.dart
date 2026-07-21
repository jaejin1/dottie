import 'package:dio/dio.dart';

import '../../features/recording/data/dot_remote_source.dart';
import '../../features/todo/data/todo_remote_source.dart' show TodoApiException;

/// 예외 객체를 사용자에게 보여줄 한국어 메시지로 변환.
///
/// 분기:
///   - [DotUploadException] : 코드별 specific 메시지 (rate limit, 태그 오류 등)
///   - [TodoApiException]   : BE error.code / statusCode 기반 메시지
///   - [DioException]       : 네트워크 vs 서버 응답 구분
///   - 그 외                : 기본 안내
String userMessageFor(Object e) {
  if (e is DotUploadException) return _dotUploadMessage(e);
  if (e is TodoApiException) return _todoApiMessage(e);
  if (e is DioException) return _dioMessage(e);
  return '문제가 발생했어요. 잠시 후 다시 시도해주세요';
}

String _todoApiMessage(TodoApiException e) {
  // BE error code(문자열)로 먼저 분기 — 있으면 가장 정확한 정보.
  switch (e.code) {
    case 'CANNOT_IMPORT_OWN':
      return '자신이 공유한 코스는 저장할 수 없어요.';
    case 'ALREADY_IMPORTED':
      return '이미 저장한 코스예요.';
    case 'NOT_FOUND' || 'SHARE_TOKEN_NOT_FOUND' || 'COURSE_NOT_FOUND':
      return '코스를 찾을 수 없어요.';
    case 'EXPIRED' || 'SHARE_TOKEN_EXPIRED' || 'INVITE_EXPIRED':
      return '링크가 만료됐어요.';
    case 'FORBIDDEN':
      return '권한이 없어요.';
    case 'COURSE_ALREADY_MEMBER':
      return '이미 참여 중인 코스예요.';
    case 'COURSE_FULL':
      return '코스 정원이 꽉 찼어요.';
    case 'INVALID_INVITE_CODE':
      return '초대 코드가 유효하지 않아요.';
    case 'OWNER_CANNOT_LEAVE':
      return '코스 소유자는 나갈 수 없어요.';
    case 'COURSE_VIEWER_FORBIDDEN':
      return '보기 전용 멤버는 수정할 수 없어요.';
  }
  // code 없으면 statusCode 기반 처리 — raw HTTP message("Not Found" 등)는 사용 안 함.
  return switch (e.statusCode) {
    401 => '로그인이 만료됐어요. 다시 로그인해주세요.',
    403 => '권한이 없어요.',
    404 => '코스를 찾을 수 없어요.',
    409 => '이미 처리된 요청이에요.',
    429 => '요청이 너무 잦아요. 잠시 후 다시 시도해주세요.',
    _ when (e.statusCode ?? 0) >= 500 =>
      '서버에 문제가 있어요. 잠시 후 다시 시도해주세요.',
    _ => e.message ?? '요청에 실패했어요. 잠시 후 다시 시도해주세요.',
  };
}

String _dotUploadMessage(DotUploadException e) {
  if (e.isRateLimited) {
    final retry = e.retryAfterSeconds ?? 60;
    return '$retry초 후에 다시 시도할 수 있어요';
  }
  return switch (e.code) {
    'INVALID_TAG_FORMAT' => '태그 형식이 올바르지 않아요',
    'TAGS_TOO_MANY' => '태그는 최대 10개까지만 가능해요',
    'INVALID_TIMESTAMP' => '시간 정보가 잘못됐어요. 다시 시도해주세요',
    'INVALID_DATE' => '날짜 형식이 올바르지 않아요',
    'INVALID_DATE_RANGE' => '시작 날짜가 종료 날짜보다 나중이에요',
    'INVALID_CURSOR' => '결과가 만료돼서 처음부터 다시 불러올게요',
    _ => e.message ?? '저장에 실패했어요. 잠시 후 다시 시도해주세요',
  };
}

String _dioMessage(DioException e) {
  // 서버가 응답한 4xx/5xx — 응답 body 의 message 추출 시도.
  if (e.response != null) {
    final body = e.response!.data;
    if (body is Map) {
      final errMap = body['error'];
      if (errMap is Map) {
        final msg = errMap['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      final msg = body['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    final status = e.response!.statusCode ?? 0;
    if (status >= 500) return '서버에 문제가 있어요. 잠시 후 다시 시도해주세요';
    if (status == 401) return '로그인이 만료됐어요. 다시 로그인해주세요';
    if (status == 403) return '권한이 없어요';
    if (status == 404) return '대상을 찾을 수 없어요';
    if (status == 409) return '이미 처리된 요청이에요';
    return '요청에 실패했어요';
  }
  // 응답이 없음 — 네트워크 실패 / timeout.
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout =>
      '응답이 늦어요. 네트워크 상태를 확인해주세요',
    DioExceptionType.connectionError =>
      '네트워크에 연결할 수 없어요',
    _ => '네트워크 오류가 발생했어요',
  };
}
