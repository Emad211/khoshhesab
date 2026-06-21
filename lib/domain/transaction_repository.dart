import 'transaction.dart';

/// اینترفیسِ خالصِ دامنه برای دسترسی به تراکنش‌ها.
/// پیاده‌سازیِ آن در لایهٔ `data` است؛ دامنه از drift بی‌خبر است (ADR-0003).
abstract class TransactionRepository {
  /// استریمِ زندهٔ همهٔ تراکنش‌ها (جدید به قدیم).
  Stream<List<Tx>> watchAll();

  /// افزودنِ یک تراکنش.
  Future<void> add(Tx tx);

  /// حذفِ یک تراکنش با شناسه.
  Future<void> remove(int id);
}
