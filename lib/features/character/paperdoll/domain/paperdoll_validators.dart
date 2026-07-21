/// 도트 캐릭터 입력 검증.
///
/// security-auditor 권고 사항:
/// - 부위 ID: `^[a-z0-9_]{1,32}$`
/// - hex 색상: `^#[0-9A-Fa-f]{6}$`
/// - 모든 검증은 클라이언트 측 안전망일 뿐, 동일 검증을 백엔드에서도 수행해야 한다.
library;

final RegExp _idPattern = RegExp(r'^[a-z0-9_]{1,32}$');
final RegExp _hexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');

/// 부위 ID 형식 검증
bool isValidPartId(String? id) {
  if (id == null || id.isEmpty) return false;
  return _idPattern.hasMatch(id);
}

/// hex 색상 형식 검증
bool isValidHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return false;
  return _hexPattern.hasMatch(hex);
}

/// 잘못된 ID는 default로 치환 (다른 사용자 데이터에 의한 크래시 방지)
String sanitizePartId(String? raw, {required String defaultId}) {
  if (isValidPartId(raw)) return raw!;
  return defaultId;
}

/// 잘못된 hex는 default로 치환 (BE는 항상 hex 값 요구).
String sanitizeHexColor(String? raw, {required String defaultHex}) {
  if (isValidHexColor(raw)) return raw!;
  return defaultHex;
}

/// face_expression은 정규식 + 화이트리스트 (BE도 동일 검증).
String sanitizeFaceExpression(String? raw, List<String> whitelist) {
  if (raw == null || !isValidPartId(raw)) return whitelist.first;
  if (!whitelist.contains(raw)) return whitelist.first;
  return raw;
}

