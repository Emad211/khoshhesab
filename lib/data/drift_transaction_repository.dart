import 'package:drift/drift.dart';

import '../core/money.dart';
import '../domain/transaction.dart';
import '../domain/transaction_repository.dart';
import 'database.dart';

/// پیاده‌سازیِ drift از ریپازیتوریِ دامنه. نگاشتِ ردیفِ drift ↔ مدلِ دامنه
/// اینجا انجام می‌شود تا دامنه از drift مستقل بماند (ADR-0003).
class DriftTransactionRepository implements TransactionRepository {
  final AppDatabase _db;

  DriftTransactionRepository(this._db);

  @override
  Stream<List<Tx>> watchAll() {
    return _db.watchAllTransactions().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  @override
  Future<void> add(Tx tx) async {
    await _db.insertTransaction(
      TransactionsCompanion.insert(
        amountRial: tx.amount.rials,
        kind: tx.kind,
        occurredAt: tx.occurredAt,
        categoryId: Value(tx.categoryId),
        category: Value(tx.category),
        note: Value(tx.note),
      ),
    );
  }

  @override
  Future<void> remove(int id) async {
    await _db.deleteTransaction(id);
  }

  Tx _toDomain(Transaction row) => Tx(
        id: row.id,
        amount: Money(row.amountRial),
        kind: row.kind,
        categoryId: row.categoryId,
        category: row.category,
        note: row.note,
        occurredAt: row.occurredAt,
      );
}
