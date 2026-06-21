import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/transaction.dart' show TxKind;

part 'database.g.dart';

/// جدولِ تراکنش‌ها. مبلغ همیشه ریالِ صحیح (ADR-0004)؛ زمان میلادیِ محلی (ADR-0005).
/// `categoryId` منبعِ کانونیِ دسته است (ADR-0003/0006)؛ ستونِ متنیِ `category`
/// به‌صورتِ snapshot/fallback حفظ می‌شود (additive محض — هرگز حذف نمی‌شود).
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountRial => integer()();
  TextColumn get kind => textEnum<TxKind>()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get category => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// جدولِ نرمالِ دسته‌ها (ADR-0006). حذف فقط با آرشیو (soft-delete) تا FKها نشکنند.
@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get kind => textEnum<TxKind>()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, kind},
      ];
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// سازندهٔ تست: دیتابیسِ درون‌حافظه‌ای (هرگز فایلِ واقعی).
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createReportIndex();
          await _seedDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          // فقط additive و idempotent (ADR-0003).
          if (from < 2) {
            await m.createTable(categories);
            await m.addColumn(transactions, transactions.categoryId);
            await _createReportIndex();
            await _seedDefaultCategories();
            await _backfillCategoryIds();
          }
        },
        beforeOpen: (details) async {
          // برای اینکه ON DELETE SET NULL واقعاً اعمال شود (در SQLite پیش‌فرض خاموش است).
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createReportIndex() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_occurred_category '
      'ON transactions (occurred_at, category_id)',
    );
  }

  Future<void> _seedDefaultCategories() async {
    const expense = [
      'خوراک', 'حمل‌ونقل', 'قبوض', 'مسکن', 'سلامت', 'خرید', 'تفریح', 'سایر',
    ];
    const income = ['حقوق', 'فروش', 'هدیه', 'سایر'];
    for (final n in expense) {
      await into(categories).insert(
        CategoriesCompanion.insert(name: n, kind: TxKind.expense),
        mode: InsertMode.insertOrIgnore,
      );
    }
    for (final n in income) {
      await into(categories).insert(
        CategoriesCompanion.insert(name: n, kind: TxKind.income),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// غنی‌سازیِ غیرمخرب: لینکِ تراکنش‌های قدیمی به دسته بر اساسِ تطبیقِ نام+نوع.
  Future<void> _backfillCategoryIds() async {
    await customStatement('''
      UPDATE transactions
      SET category_id = (
        SELECT c.id FROM categories c
        WHERE c.name = transactions.category AND c.kind = transactions.kind
      )
      WHERE category IS NOT NULL AND category_id IS NULL
    ''');
  }

  // ---- transactions ----
  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<int> deleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  // ---- categories ----
  Stream<List<CategoryRow>> watchCategories({TxKind? kind}) {
    final q = select(categories)..where((c) => c.isArchived.equals(false));
    if (kind != null) q.where((c) => c.kind.equalsValue(kind));
    q.orderBy([(c) => OrderingTerm.asc(c.id)]);
    return q.watch();
  }

  Future<List<CategoryRow>> getAllCategories() => select(categories).get();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry, mode: InsertMode.insertOrIgnore);

  Future<void> archiveCategory(int id) async {
    await (update(categories)..where((c) => c.id.equals(id)))
        .write(const CategoriesCompanion(isArchived: Value(true)));
  }

  // ---- report aggregation (SUM/GROUP BY در SQL — ADR-0006) ----
  Future<List<CategorySpendRow>> categorySpending({
    required DateTime start,
    required DateTime end,
    required TxKind kind,
  }) async {
    final total = transactions.amountRial.sum();
    final q = selectOnly(transactions)
      ..addColumns([transactions.categoryId, total])
      ..where(transactions.occurredAt.isBiggerOrEqualValue(start) &
          transactions.occurredAt.isSmallerThanValue(end) &
          transactions.kind.equalsValue(kind))
      ..groupBy([transactions.categoryId]);
    final rows = await q.get();
    return rows
        .map((r) => CategorySpendRow(
              categoryId: r.read(transactions.categoryId),
              totalRial: r.read(total) ?? 0,
            ))
        .toList();
  }

  Future<int> totalByKind({
    required DateTime start,
    required DateTime end,
    required TxKind kind,
  }) async {
    final total = transactions.amountRial.sum();
    final q = selectOnly(transactions)
      ..addColumns([total])
      ..where(transactions.occurredAt.isBiggerOrEqualValue(start) &
          transactions.occurredAt.isSmallerThanValue(end) &
          transactions.kind.equalsValue(kind));
    final row = await q.getSingle();
    return row.read(total) ?? 0;
  }
}

/// ردیفِ خامِ تجمیعِ گزارش (categoryId + مجموعِ ریال).
class CategorySpendRow {
  final int? categoryId;
  final int totalRial;
  CategorySpendRow({required this.categoryId, required this.totalRial});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'khosh_hesab.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
