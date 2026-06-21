import 'package:flutter_test/flutter_test.dart';
import 'package:khosh_hesab/domain/jalali_month.dart';

void main() {
  group('JalaliMonth (ADR-0006)', () {
    test('fromDateTime — ۲۰۲۶/۰۶/۲۱ = خرداد ۱۴۰۵', () {
      final m = JalaliMonth.fromDateTime(DateTime(2026, 6, 21));
      expect(m.year, 1405);
      expect(m.month, 3);
    });

    test('مرزِ میلادیِ ماهِ شمسی (خرداد ۱۴۰۵)', () {
      const m = JalaliMonth(1405, 3);
      expect(m.gregorianStart(), DateTime(2026, 5, 22));
      expect(m.gregorianEnd(), DateTime(2026, 6, 22));
    });

    test('next/previous و مرزِ سال', () {
      expect(const JalaliMonth(1405, 12).next(), const JalaliMonth(1406, 1));
      expect(const JalaliMonth(1405, 1).previous(), const JalaliMonth(1404, 12));
    });

    test('برابری و compareTo', () {
      expect(const JalaliMonth(1405, 3) == const JalaliMonth(1405, 3), true);
      expect(const JalaliMonth(1405, 2).compareTo(const JalaliMonth(1405, 3)) < 0, true);
      expect(const JalaliMonth(1406, 1).compareTo(const JalaliMonth(1405, 12)) > 0, true);
    });

    test('label فارسی', () {
      expect(const JalaliMonth(1405, 3).label(), 'خرداد ۱۴۰۵');
    });
  });
}
