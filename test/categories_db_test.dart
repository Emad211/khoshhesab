import 'package:flutter_test/flutter_test.dart';
import 'package:khosh_hesab/core/money.dart';
import 'package:khosh_hesab/data/database.dart';
import 'package:khosh_hesab/data/drift_category_repository.dart';
import 'package:khosh_hesab/data/drift_transaction_repository.dart';
import 'package:khosh_hesab/domain/jalali_month.dart';
import 'package:khosh_hesab/domain/transaction.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() async => db.close());

  test('onCreate دسته‌های پیش‌فرض را seed می‌کند', () async {
    final cats = await db.getAllCategories();
    expect(cats.where((c) => c.kind == TxKind.expense).length, 8);
    expect(cats.where((c) => c.kind == TxKind.income).length, 4);
    // «سایر» در هر دو نوع مجاز است (UNIQUE روی name+kind)
    expect(cats.where((c) => c.name == 'سایر').length, 2);
  });

  test('تجمیعِ هزینه بر دسته در ماهِ شمسی درست است', () async {
    final txRepo = DriftTransactionRepository(db);
    final cats = await db.getAllCategories();
    final khorak = cats.firstWhere((c) => c.name == 'خوراک' && c.kind == TxKind.expense);
    final maskan = cats.firstWhere((c) => c.name == 'مسکن' && c.kind == TxKind.expense);
    final d = DateTime(2026, 6, 10); // خرداد ۱۴۰۵

    await txRepo.add(Tx(amount: Money.fromToman(1000), kind: TxKind.expense, categoryId: khorak.id, category: 'خوراک', occurredAt: d));
    await txRepo.add(Tx(amount: Money.fromToman(500), kind: TxKind.expense, categoryId: khorak.id, category: 'خوراک', occurredAt: d));
    await txRepo.add(Tx(amount: Money.fromToman(2000), kind: TxKind.expense, categoryId: maskan.id, category: 'مسکن', occurredAt: d));
    await txRepo.add(Tx(amount: Money.fromToman(9999), kind: TxKind.income, occurredAt: d));

    final repo = DriftCategoryRepository(db);
    final slices = await repo.categorySpending(const JalaliMonth(1405, 3), kind: TxKind.expense);
    final byName = {for (final s in slices) s.name: s.totalRial};

    expect(byName['خوراک'], 15000); // ۱۵۰۰ تومان = ۱۵۰۰۰ ریال
    expect(byName['مسکن'], 20000);
    expect(slices.any((s) => s.totalRial == 99990), false); // درآمد در هزینه نیاید

    final totals = await repo.monthlyTotals(const JalaliMonth(1405, 3));
    expect(totals.expenseRial, 35000);
    expect(totals.incomeRial, 99990);
  });

  test('تراکنشِ خارج از ماه در گزارش نمی‌آید', () async {
    final txRepo = DriftTransactionRepository(db);
    final khorak = (await db.getAllCategories())
        .firstWhere((c) => c.name == 'خوراک' && c.kind == TxKind.expense);
    // تیر ۱۴۰۵ (خارج از خرداد)
    await txRepo.add(Tx(amount: Money.fromToman(1000), kind: TxKind.expense, categoryId: khorak.id, occurredAt: DateTime(2026, 7, 1)));

    final slices = await DriftCategoryRepository(db)
        .categorySpending(const JalaliMonth(1405, 3), kind: TxKind.expense);
    expect(slices.isEmpty, true);
  });
}
