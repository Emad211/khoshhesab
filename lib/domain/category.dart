import '../core/money.dart';
import 'transaction.dart' show TxKind;

/// مدلِ دامنهٔ دسته — مستقل از drift (ADR-0006).
class Category {
  final int? id;
  final String name;
  final TxKind kind;
  final bool isArchived;

  const Category({
    this.id,
    required this.name,
    required this.kind,
    this.isArchived = false,
  });
}

/// یک «برش» از تجمیعِ گزارش: مجموعِ یک دسته در یک بازه.
class CategorySlice {
  final int? categoryId;
  final String name;
  final TxKind kind;
  final int totalRial;

  const CategorySlice({
    required this.categoryId,
    required this.name,
    required this.kind,
    required this.totalRial,
  });

  Money get total => Money(totalRial);
}
