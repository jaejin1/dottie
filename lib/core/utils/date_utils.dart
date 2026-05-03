import 'package:intl/intl.dart';

class DottieDateUtils {
  DottieDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _fullFormat = DateFormat('yyyy년 M월 d일');
  static final DateFormat _weekdayFormat = DateFormat('EEEE', 'ko_KR');
  static final DateFormat _monthDayFormat = DateFormat('M월 d일', 'ko_KR');
  static final DateFormat _yearMonthFormat = DateFormat('yyyy년 M월', 'ko_KR');

  // BE 가 보낸 타임스탬프(`...Z` UTC) 가 그대로 들어와도 OS 타임존으로 변환해서 포맷.
  // `DateFormat.format()` 은 UTC DateTime 을 변환 없이 UTC 시각 그대로 출력하므로
  // `.toLocal()` 을 명시 호출해야 사용자 환경 시각으로 보임.
  // (이미 local DateTime 이면 toLocal() 은 no-op — 안전)

  static String toDateString(DateTime dt) =>
      _dateFormat.format(dt.toLocal());
  static String toTimeString(DateTime dt) =>
      _timeFormat.format(dt.toLocal());
  static String toKoreanDate(DateTime dt) =>
      _fullFormat.format(dt.toLocal());

  /// "월요일", "일요일" 등 한국어 요일.
  /// 호출 전 main 에서 initializeDateFormatting('ko_KR') 필요.
  static String toKoreanWeekday(DateTime dt) =>
      _weekdayFormat.format(dt.toLocal());

  /// "5월 3일" — 연도 생략. 같은 해 안의 날짜를 표시할 때.
  static String toKoreanMonthDay(DateTime dt) =>
      _monthDayFormat.format(dt.toLocal());

  /// "2026년 5월" — 캘린더 월 헤더용.
  static String toKoreanYearMonth(DateTime dt) =>
      _yearMonthFormat.format(dt.toLocal());

  /// 오늘이면 "오늘", 어제면 "어제", 내일이면 "내일", 그 외엔 null.
  /// 상단 바 타이틀의 요일 자리를 자연스러운 라벨로 대체할 때 사용.
  static String? relativeLabel(DateTime dt) {
    final today = todayStart();
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    return switch (diff) {
      0 => '오늘',
      -1 => '어제',
      1 => '내일',
      _ => null,
    };
  }

  static DateTime todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
