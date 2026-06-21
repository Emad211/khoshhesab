import '../core/money.dart';

/// نوعِ تراکنش (ADR-0003). در DB با `textEnum` ذخیره می‌شود.
enum TxKind { income, expense }

/// مدلِ دامنهٔ تراکنش — مستقل از فریم‌ورک/دیتابیس (لایه‌بندیِ ADR-0001 §۵).
class Tx {
  final int? id;
  final Money amount;
  final TxKind kind;

  /// منبعِ کانونیِ دسته (ADR-0006). برای رکوردهای بدونِ دسته null است.
  final int? categoryId;

  /// snapshot/fallbackِ نامِ دسته برای نمایشِ سریع و سازگاریِ عقب‌رو.
  final String? category;

  final String? note;
  final DateTime occurredAt;

  const Tx({
    this.id,
    required this.amount,
    required this.kind,
    this.categoryId,
    this.category,
    this.note,
    required this.occurredAt,
  });

  /// مبلغِ علامت‌دار برای محاسبهٔ مانده: درآمد مثبت، هزینه منفی.
  Money get signedAmount => kind == TxKind.expense ? -amount : amount;
}
