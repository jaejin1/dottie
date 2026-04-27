import 'package:intl/intl.dart';

class DottieDateUtils {
  DottieDateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _fullFormat = DateFormat('yyyy년 M월 d일');

  static String toDateString(DateTime dt) => _dateFormat.format(dt);
  static String toTimeString(DateTime dt) => _timeFormat.format(dt);
  static String toKoreanDate(DateTime dt) => _fullFormat.format(dt);

  static DateTime todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
