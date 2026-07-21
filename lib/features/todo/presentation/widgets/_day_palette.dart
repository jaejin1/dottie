import 'package:flutter/material.dart';

/// 여행 코스의 day 별 색상 언어 — 지도 라인/핀, 리스트 헤더, Day 칩이
/// 같은 팔레트를 공유해 "색 = 일정" 이 화면 간 일관되게 읽히도록 한다.
/// dayIndex % length 순환.
const kDayColorHexes = [
  '#E8836B', // Day 1 — primary
  '#5B8DEF',
  '#4CAF82',
  '#F0A64F',
  '#9B7EDE',
  '#E86B9A',
  '#50B8C8',
  '#8A9B6B',
];

String dayColorHexOf(int dayIndex) =>
    kDayColorHexes[dayIndex < 0 ? 0 : dayIndex % kDayColorHexes.length];

Color dayColorOf(int dayIndex) {
  final hex = dayColorHexOf(dayIndex).substring(1);
  return Color(0xFF000000 | int.parse(hex, radix: 16));
}
