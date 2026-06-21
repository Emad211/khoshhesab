import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../data/database.dart';
import '../data/drift_category_repository.dart';
import '../data/drift_transaction_repository.dart';
import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/jalali_month.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';

/// پروایدرهای Riverpod (دستی) — ADR-0002.

/// چرخهٔ عمرِ دیتابیس.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// ریپازیتوریِ تراکنش (اینترفیسِ دامنه؛ پیاده‌سازیِ drift).
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return DriftTransactionRepository(ref.watch(databaseProvider));
});

/// ریپازیتوریِ دسته/گزارش (یک پیاده‌سازی، دو اینترفیس).
final categoryRepositoryProvider = Provider<DriftCategoryRepository>((ref) {
  return DriftCategoryRepository(ref.watch(databaseProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ref.watch(categoryRepositoryProvider);
});

/// استریمِ واکنشیِ تراکنش‌ها → UI خودکار به‌روز می‌شود.
final transactionsProvider = StreamProvider<List<Tx>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// ماندهٔ کل (درآمد − هزینه) از روی تراکنش‌های جاری.
final balanceProvider = Provider<Money>((ref) {
  final txs = ref.watch(transactionsProvider).valueOrNull ?? const <Tx>[];
  return txs.fold(const Money.zero(), (sum, t) => sum + t.signedAmount);
});

/// دسته‌های فعال، فیلترشده بر نوع.
final categoriesProvider =
    StreamProvider.family<List<Category>, TxKind?>((ref, kind) {
  return ref.watch(categoryRepositoryProvider).watchAll(kind: kind);
});

/// ماهِ شمسیِ انتخاب‌شده در صفحهٔ گزارش (پیش‌فرض: ماهِ جاری).
final selectedReportMonthProvider = StateProvider<JalaliMonth>((ref) {
  return JalaliMonth.fromDateTime(DateTime.now());
});

/// سهمِ دسته‌های هزینه در ماهِ انتخاب‌شده (برای نمودار). با تغییرِ تراکنش‌ها بازمحاسبه می‌شود.
final categorySpendingProvider =
    FutureProvider.family<List<CategorySlice>, JalaliMonth>((ref, month) {
  ref.watch(transactionsProvider);
  return ref.watch(reportRepositoryProvider).categorySpending(month, kind: TxKind.expense);
});

/// مجموعِ درآمد/هزینهٔ ماهِ انتخاب‌شده (برای کارت‌های خلاصه).
final monthlyTotalsProvider =
    FutureProvider.family<({int incomeRial, int expenseRial}), JalaliMonth>((ref, month) {
  ref.watch(transactionsProvider);
  return ref.watch(reportRepositoryProvider).monthlyTotals(month);
});
