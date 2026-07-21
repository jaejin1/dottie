/// 사용자 입력 검증 유틸. IME 미완성 / 빈 입력 / 너무 짧은 입력 가드.
///
/// 가장 흔한 케이스: Android 한글 IME 에서 자모(`ㄱ`, `ㅏ` 등) 입력 중 사용자가
/// 엔터 또는 저장 버튼을 누르면 `controller.text` 가 미완성 자모 그대로 들어옴.
/// 룸 이름이 "ㄴ" 으로 저장되는 등의 버그가 발생.
class TextValidators {
  TextValidators._();

  /// 문자열에 한글 *자모 단독* (완성형이 아닌 미완성 자음/모음) 이 *포함*돼 있는지.
  /// 정상적인 IME 완료 입력에는 자모 단독이 나오지 않음.
  static bool hasHangulJamo(String s) {
    return s.runes.any(_isHangulJamo);
  }

  /// 빈 문자열 또는 자모 단독만 있는 입력 → invalid.
  ///
  /// 일반 텍스트(영문/숫자/공백 포함 한글) 는 모두 valid.
  /// 사용자 친화 메시지: "글자를 완성해주세요" 등.
  static bool isValidUserText(String s) {
    final t = s.trim();
    if (t.isEmpty) return false;
    if (hasHangulJamo(t)) return false;
    return true;
  }

  /// Hangul Jamo (compatibility / standard / extended) 코드 포인트 검사.
  ///   - U+3131~U+318E: 호환 자모 (ㄱㄴㄷ, ㅏㅑㅓ 등)
  ///   - U+1100~U+11FF: 표준 자모 (조합형 IME 임시 글자)
  ///   - U+A960~U+A97F: 확장-A
  ///   - U+D7B0~U+D7FF: 확장-B
  static bool _isHangulJamo(int code) {
    return (code >= 0x3131 && code <= 0x318E) ||
        (code >= 0x1100 && code <= 0x11FF) ||
        (code >= 0xA960 && code <= 0xA97F) ||
        (code >= 0xD7B0 && code <= 0xD7FF);
  }
}
