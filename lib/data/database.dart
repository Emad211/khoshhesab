import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/transaction.dart' show TxKind;

part 'database.g.dart';

/// جدولِ تراکنش‌ها. مبلغ همیشه ریالِ صحیح (ADR-0004)؛
/// زمان به میلادیِ محلیِ ایران ذخیره و به شمسی نمایش داده می‌شود (ADR-0005).
///
/// نکتهٔ اسکلت: «دسته» فعلاً ستونِ متنی است؛ نرمال‌سازی به جدولِ `categories`
/// نخستین کارِ فاز ۲ است (ADR-0003).
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get amountRial => integer()();
  TextColumn get kind => textEnum<TxKind>()();
  TextColumn get category => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  /// سازندهٔ تست: دیتابیسِ درون‌حافظه‌ای (هرگز فایلِ واقعی).
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // فقط additive — هرگز حذف/تغییرِ مخرب (ADR-0003).
        },
      );

  Stream<List<Transaction>> watchAllTransactions() {
    return (select(transactions)
          ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
        .watch();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) {
    return into(transactions).insert(entry);
  }

  Future<int> deleteTransaction(int id) {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }
}

/// پایگاه‌داده روی فایلِ محلیِ گوشی؛ بدونِ هیچ سرویسِ گوگل (ADR-0001/0003).
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'khosh_hesab.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
