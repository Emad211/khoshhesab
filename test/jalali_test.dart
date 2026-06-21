import 'package:flutter_test/flutter_test.dart';
import 'package:khosh_hesab/core/fa.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() {
  group('تاریخِ شمسی (ADR-0005)', () {
    test('۲۰۲۶-۰۶-۲۱ میلادی = ۱۴۰۵/۰۳/۳۱ شمسی', () {
      final j = Jalali.fromDateTime(DateTime(2026, 6, 21));
      expect(j.year, 1405);
      expect(j.month, 3);
      expect(j.day, 31);
    });

    test('formatJalali ارقامِ فارسی می‌دهد', () {
      expect(formatJalali(DateTime(2026, 6, 21)), '۱۴۰۵/۰۳/۳۱');
    });
  });

  group('ارقامِ فارسی', () {
    test('toFaDigits', () {
      expect(toFaDigits('123'), '۱۲۳');
      expect(toFaDigits('2026/06'), '۲۰۲۶/۰۶');
    });
  });
}
