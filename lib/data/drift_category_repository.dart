import '../domain/category.dart';
import '../domain/category_repository.dart';
import '../domain/jalali_month.dart';
import '../domain/transaction.dart' show TxKind;
import 'database.dart';

/// پیاده‌سازیِ drift از ریپازیتوریِ دسته و گزارش. SQL در `database.dart` می‌ماند؛
/// اینجا فقط نگاشتِ ردیف↔دامنه و ترکیبِ نتایج انجام می‌شود (ADR-0003).
class DriftCategoryRepository implements CategoryRepository, ReportRepository {
  final AppDatabase _db;

  DriftCategoryRepository(this._db);

  @override
  Stream<List<Category>> watchAll({TxKind? kind}) {
    return _db.watchCategories(kind: kind).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  @override
  Future<int> add(Category category) {
    return _db.insertCategory(
      CategoriesCompanion.insert(name: category.name, kind: category.kind),
    );
  }

  @override
  Future<void> archive(int id) => _db.archiveCategory(id);

  @override
  Future<List<CategorySlice>> categorySpending(
    JalaliMonth month, {
    required TxKind kind,
  }) async {
    final rows = await _db.categorySpending(
      start: month.gregorianStart(),
      end: month.gregorianEnd(),
      kind: kind,
    );
    final cats = await _db.getAllCategories();
    final nameById = {for (final c in cats) c.id: c.name};
    return rows
        .map((r) => CategorySlice(
              categoryId: r.categoryId,
              name: r.categoryId == null
                  ? 'بدون دسته'
                  : (nameById[r.categoryId] ?? 'بدون دسته'),
              kind: kind,
              totalRial: r.totalRial,
            ))
        .toList();
  }

  @override
  Future<({int incomeRial, int expenseRial})> monthlyTotals(JalaliMonth month) async {
    final start = month.gregorianStart();
    final end = month.gregorianEnd();
    final income = await _db.totalByKind(start: start, end: end, kind: TxKind.income);
    final expense = await _db.totalByKind(start: start, end: end, kind: TxKind.expense);
    return (incomeRial: income, expenseRial: expense);
  }

  Category _toDomain(CategoryRow row) => Category(
        id: row.id,
        name: row.name,
        kind: row.kind,
        isArchived: row.isArchived,
      );
}
