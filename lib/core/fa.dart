import 'package:shamsi_date/shamsi_date.dart';

import 'money.dart';

/// قالب‌بندیِ فارسی/شمسی — یک نقطهٔ واحدِ تبدیل/نمایش (ADR-0004/0005).

const List<String> _faDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// ارقامِ لاتین → فارسی.
String toFaDigits(String input) {
  final sb = StringBuffer();
  for (final ch in input.split('')) {
    final code = ch.codeUnitAt(0);
    if (code >= 48 && code <= 57) {
      sb.write(_faDigits[code - 48]);
    } else {
      sb.write(ch);
    }
  }
  return sb.toString();
}

/// جداکنندهٔ هزارگان روی عددِ صحیحِ نامنفی.
String _grouped(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('٬');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// نمایشِ پول به تومانِ فارسی، با علامتِ منفی برای بدهی/هزینه.
String formatToman(Money money) {
  final sign = money.isNegative ? '−' : '';
  final t = money.toman.abs();
  return '$sign${toFaDigits(_grouped(t))} تومان';
}

/// نمایشِ تاریخِ میلادی به شمسیِ فارسی به‌صورتِ YYYY/MM/DD.
String formatJalali(DateTime dt) {
  final j = Jalali.fromDateTime(dt);
  final mm = j.month.toString().padLeft(2, '0');
  final dd = j.day.toString().padLeft(2, '0');
  return toFaDigits('${j.year}/$mm/$dd');
}
