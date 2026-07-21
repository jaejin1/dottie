import 'package:flutter/material.dart';

/// 사용자 정체성 색 default — 신규 가입자/파싱 실패 시 폴백.
/// BE의 default와 동일.
const String kCharacterColorHexDefault = '#7EB8F7';

/// 캐릭터 에디터의 빠른 선택 프리셋 (5색).
/// BE 가독성 제약(S>=0.25, V 0.30~0.95)을 모두 만족하도록 조정됨.
/// - 원본 coral(#FF8FAB)은 V=1.0이라 검증 실패 → 0.95로 스케일 다운
const List<String> kCharacterColorPresetsHex = [
  '#7EB8F7', // blue
  '#7ED6C8', // mint
  '#F288A3', // coral (V=0.95로 조정. 원본 #FF8FAB는 V=1.0)
  '#B8A8F5', // lavender
  '#D9B83A', // yellow
];

final RegExp _hexPattern = RegExp(r'^#[0-9A-Fa-f]{6}$');

/// hex 문자열을 [Color]로 변환. 잘못된 형식이면 [fallback].
Color colorFromHex(String? hex,
    {Color fallback = const Color(0xFF7EB8F7)}) {
  if (hex == null || !_hexPattern.hasMatch(hex)) return fallback;
  final value = int.parse(hex.substring(1), radix: 16);
  return Color(0xFF000000 | value);
}

/// [Color]를 `#RRGGBB` 문자열로 변환 (alpha 무시).
String hexFromColor(Color c) {
  final r = (c.r * 255).round() & 0xFF;
  final g = (c.g * 255).round() & 0xFF;
  final b = (c.b * 255).round() & 0xFF;
  final v = (r << 16) | (g << 8) | b;
  return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// BE의 가독성 제약과 동일한 검증 (HSV 기반).
/// - saturation >= 0.25 (회색/흰색/검정 차단)
/// - 0.30 <= value <= 0.95 (너무 어둡거나 너무 밝지 않게)
bool isReadableHex(String hex) {
  if (!_hexPattern.hasMatch(hex)) return false;
  final hsv = HSVColor.fromColor(colorFromHex(hex));
  return hsv.saturation >= 0.25 &&
      hsv.value >= 0.30 &&
      hsv.value <= 0.95;
}

/// hex가 가독성 제약을 위반하는 경우의 사유.
/// BE 응답의 `reason` 필드(`too_dark` / `too_light` / `too_gray`)와 동일.
enum ReadabilityIssue { tooDark, tooLight, tooGray }

ReadabilityIssue? readabilityIssue(String hex) {
  if (!_hexPattern.hasMatch(hex)) return null;
  final hsv = HSVColor.fromColor(colorFromHex(hex));
  if (hsv.saturation < 0.25) return ReadabilityIssue.tooGray;
  if (hsv.value < 0.30) return ReadabilityIssue.tooDark;
  if (hsv.value > 0.95) return ReadabilityIssue.tooLight;
  return null;
}

extension ReadabilityIssueLabel on ReadabilityIssue {
  String get koLabel => switch (this) {
        ReadabilityIssue.tooDark => '너무 어두운 색이에요',
        ReadabilityIssue.tooLight => '너무 밝은 색이에요',
        ReadabilityIssue.tooGray => '너무 흐릿한 색이에요',
      };
}

/// hex 문자열을 sanitize. 형식이 맞으면 그대로, 아니면 [defaultHex].
/// (가독성은 검증하지 않음 — BE가 수용한 값은 표시 가능해야 한다는 가정)
String sanitizeColorHex(String? raw, {required String defaultHex}) {
  if (raw == null) return defaultHex;
  return _hexPattern.hasMatch(raw) ? raw : defaultHex;
}
