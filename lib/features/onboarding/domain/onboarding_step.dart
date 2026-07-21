enum OnboardingStep {
  idle,
  dotFab,
  dotSheet,
  mapHint,       // 캘린더 아이콘 spotlight
  calendarDay,   // 오늘 날짜 셀 spotlight → 지도 진입 유도
  bottomTabRoom, // 하단 탭으로 방 이동 유도
  room,
  character,
  done,
}
