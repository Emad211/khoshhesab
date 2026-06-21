import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/money.dart';
import '../data/database.dart';
import '../data/drift_transaction_repository.dart';
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

/// استریمِ واکنشیِ تراکنش‌ها → UI خودکار به‌روز می‌شود.
final transactionsProvider = StreamProvider<List<Tx>>((ref) {
  return ref.watch(transactionRepositoryProvider).watchAll();
});

/// ماندهٔ کل (درآمد − هزینه) از روی تراکنش‌های جاری.
final balanceProvider = Provider<Money>((ref) {
  final txs = ref.watch(transactionsProvider).valueOrNull ?? const <Tx>[];
  return txs.fold(const Money.zero(), (sum, t) => sum + t.signedAmount);
});
