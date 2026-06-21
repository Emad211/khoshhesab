import 'package:shamsi_date/shamsi_date.dart';

import '../core/fa.dart';

/// value-objectِ تغییرناپذیرِ «ماهِ شمسی» — تنها مرجعِ گروه‌بندیِ زمانیِ گزارش (ADR-0005/0006).
/// مرزِ ماهِ شمسی را به دو `DateTime` میلادیِ محلی تبدیل می‌کند تا کوئری بازه‌ای بزند
/// (هرگز strftime یا برشِ ماهِ میلادی).
class JalaliMonth {
  final int year;
  final int month;

  const JalaliMonth(this.year, this.month);

  factory JalaliMonth.fromDateTime(DateTime dt) {
    final j = Jalali.fromDateTime(dt);
    return JalaliMonth(j.year, j.month);
  }

  /// اولِ ماهِ شمسی (نیمه‌بازِ شروع).
  DateTime gregorianStart() {
    final g = Jalali(year, month, 1).toGregorian();
    return DateTime(g.year, g.month, g.day);
  }

  /// اولِ ماهِ شمسیِ بعد (نیمه‌بازِ پایان: [start, end)).
  DateTime gregorianEnd() {
    final ny = month == 12 ? year + 1 : year;
    final nm = month == 12 ? 1 : month + 1;
    final g = Jalali(ny, nm, 1).toGregorian();
    return DateTime(g.year, g.month, g.day);
  }

  JalaliMonth next() =>
      month == 12 ? JalaliMonth(year + 1, 1) : JalaliMonth(year, month + 1);

  JalaliMonth previous() =>
      month == 1 ? JalaliMonth(year - 1, 12) : JalaliMonth(year, month - 1);

  static const _names = [
    'فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور',
    'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند',
  ];

  String label() => '${_names[month - 1]} ${toFaDigits(year.toString())}';

  int compareTo(JalaliMonth other) =>
      year != other.year ? year.compareTo(other.year) : month.compareTo(other.month);

  @override
  bool operator ==(Object other) =>
      other is JalaliMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}
