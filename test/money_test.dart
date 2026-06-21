import 'package:flutter_test/flutter_test.dart';
import 'package:khosh_hesab/core/money.dart';

void main() {
  group('Money — ریالِ صحیح (ADR-0004)', () {
    test('fromToman به ریال ذخیره می‌کند', () {
      expect(Money.fromToman(1500).rials, 15000);
      expect(Money.fromToman(1500).toman, 1500);
    });

    test('جمع و تفریق', () {
      expect((Money.fromToman(1000) + Money.fromToman(500)).toman, 1500);
      expect((Money.fromToman(1000) - Money.fromToman(1500)).toman, -500);
    });

    test('علامتِ منفی و صفر', () {
      expect((Money.fromToman(1000) - Money.fromToman(3000)).isNegative, true);
      expect(const Money.zero().isZero, true);
    });

    test('ضرب در اسکالر', () {
      expect((Money.fromToman(250) * 4).toman, 1000);
    });

    test('برابری و hashCode', () {
      expect(Money.fromToman(20), const Money(200));
      expect(Money.fromToman(20).hashCode, const Money(200).hashCode);
    });
  });
}
