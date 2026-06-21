import 'category.dart';
import 'jalali_month.dart';
import 'transaction.dart' show TxKind;

/// اینترفیسِ خالصِ دامنه برای دسته‌ها — بدونِ هیچ ارجاع به drift (ADR-0003).
abstract class CategoryRepository {
  Stream<List<Category>> watchAll({TxKind? kind});
  Future<int> add(Category category);
  Future<void> archive(int id);
}

/// اینترفیسِ گزارش — تجمیعِ ماهِ شمسی.
abstract class ReportRepository {
  /// سهمِ هر دسته از یک نوع (income/expense) در یک ماهِ شمسی.
  Future<List<CategorySlice>> categorySpending(JalaliMonth month, {required TxKind kind});

  /// مجموعِ درآمد و هزینهٔ یک ماهِ شمسی (برای کارت‌های خلاصه).
  Future<({int incomeRial, int expenseRial})> monthlyTotals(JalaliMonth month);
}
