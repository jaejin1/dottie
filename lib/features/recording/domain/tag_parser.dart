/// dot 메모에서 `#태그` 를 추출/정규화 하는 순수 함수 모음.
///
/// FE/BE 가 동일한 규칙을 사용해야 검색 결과가 어긋나지 않으므로,
/// 정규화 규칙은 BE 와 1:1 매칭됨:
/// - lowercase + trim
/// - 허용 문자: `\p{L}` (모든 언어 letter) / `\p{N}` (숫자) / `_`
/// - 최대 길이 30자, dot 당 최대 10개
/// - 중복 제거, 빈 문자열 제거
class TagParser {
  TagParser._();

  static const int maxTagLength = 30;
  static const int maxTagsPerDot = 10;

  /// 메모 본문에서 `#xxx` 토큰을 찾아 정규화된 태그 리스트로 반환.
  /// 결과는 dedup + cap 적용. 입력 순서 보존.
  static List<String> extractFromText(String? memo) {
    if (memo == null || memo.isEmpty) return const [];
    final matches = _hashtagPattern.allMatches(memo);
    final raw = matches.map((m) => m.group(1)!).toList();
    return normalizeAll(raw);
  }

  /// 단일 태그 정규화. 형식 위반/빈값이면 null.
  /// 입력은 `#` 제외 본문 (예: "회의").
  static String? normalize(String input) {
    final trimmed = input.trim().toLowerCase();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > maxTagLength) return null;
    if (!_validTagPattern.hasMatch(trimmed)) return null;
    return trimmed;
  }

  /// 다중 태그 정규화 + 중복 제거 + 개수 cap.
  /// 입력이 raw(예: 사용자가 친 그대로)라고 가정.
  static List<String> normalizeAll(Iterable<String> tags) {
    final seen = <String>{};
    final out = <String>[];
    for (final t in tags) {
      final n = normalize(t);
      if (n == null) continue;
      if (!seen.add(n)) continue;
      out.add(n);
      if (out.length >= maxTagsPerDot) break;
    }
    return out;
  }

  /// 메모 표시 / 입력 강조용 — 토큰 단위로 분할.
  /// `[("점심 ", false), ("#회의", true), (" ", false), ("#피곤", true)]` 형태.
  static List<({String text, bool isTag})> tokenize(String memo) {
    if (memo.isEmpty) return const [];
    final result = <({String text, bool isTag})>[];
    var cursor = 0;
    for (final m in _hashtagPattern.allMatches(memo)) {
      if (m.start > cursor) {
        result.add((text: memo.substring(cursor, m.start), isTag: false));
      }
      result.add((text: memo.substring(m.start, m.end), isTag: true));
      cursor = m.end;
    }
    if (cursor < memo.length) {
      result.add((text: memo.substring(cursor), isTag: false));
    }
    return result;
  }

  /// 입력 캐럿 위치에서 활성 태그 prefix 를 반환 (자동완성용).
  /// 예: "점심 #회|" → "회". 활성 prefix 없으면 null.
  /// caret 직전이 `#xxx` 토큰의 일부일 때만 동작 (공백 다음이면 null).
  static String? activePrefix(String memo, int caretOffset) {
    if (caretOffset < 0 || caretOffset > memo.length) return null;
    var i = caretOffset - 1;
    final buf = StringBuffer();
    final chars = <int>[];
    while (i >= 0) {
      final ch = memo.codeUnitAt(i);
      if (ch == _hashChar) {
        // `#` 발견 — buf 에 쌓인 게 prefix
        final raw = String.fromCharCodes(chars.reversed);
        // 빈 prefix(`#` 만 친 직후)도 자동완성 트리거 — 빈 문자열 반환
        if (raw.isEmpty) return '';
        if (!_partialTagPattern.hasMatch(raw)) return null;
        return raw.toLowerCase();
      }
      if (!_partialTagCharPattern.hasMatch(String.fromCharCode(ch))) {
        // 태그 글자가 아닌 게 끼어들면 활성 prefix 아님
        return null;
      }
      chars.add(ch);
      buf.writeCharCode(ch);
      i--;
    }
    return null;
  }

  /// `#xxx` 토큰 패턴 (group 1 = `#` 제외 본문).
  /// `\p{L}` 한글/영문 모두 매칭. `unicode: true` 필수.
  /// 길이 제한은 `normalize` 에서 검증 — 30자 초과 입력은 reject 되어야지
  /// 30자에서 잘려 어색하게 저장되면 안 됨.
  static final RegExp _hashtagPattern =
      RegExp(r'#([\p{L}\p{N}_]+)', unicode: true);

  /// 정규화 후 검증 — 정확히 허용 문자만 1~30자.
  static final RegExp _validTagPattern =
      RegExp(r'^[\p{L}\p{N}_]{1,30}$', unicode: true);

  /// 부분 매칭 (입력 중) — 길이 제약 없이 허용 문자만.
  static final RegExp _partialTagPattern =
      RegExp(r'^[\p{L}\p{N}_]+$', unicode: true);

  /// 단일 글자 검증 (활성 prefix 추적용).
  static final RegExp _partialTagCharPattern =
      RegExp(r'[\p{L}\p{N}_]', unicode: true);

  static const int _hashChar = 0x23; // '#'
}
