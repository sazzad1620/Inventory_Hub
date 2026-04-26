import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
}

class Session extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get userId => integer()
      .nullable()
      .references(Users, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer()
      .nullable()
      .references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get buyingPrice => integer()();
  IntColumn get sellingPrice => integer()();
  IntColumn get stock => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users, Session, Products])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await customStatement('PRAGMA foreign_keys = OFF;');
            await customStatement('''
              CREATE TABLE session_new (
                id INTEGER NOT NULL DEFAULT 1 PRIMARY KEY,
                user_id INTEGER NULL REFERENCES users (id) ON DELETE SET NULL
              );
            ''');
            await customStatement('''
              INSERT INTO session_new (id, user_id)
              SELECT id, user_id FROM session;
            ''');
            await customStatement('DROP TABLE session;');
            await customStatement('ALTER TABLE session_new RENAME TO session;');
            await customStatement('PRAGMA foreign_keys = ON;');
          }
          if (from < 3) {
            await customStatement('''
              CREATE TABLE products_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NULL REFERENCES users (id) ON DELETE CASCADE,
                name TEXT NOT NULL,
                buying_price INTEGER NOT NULL,
                selling_price INTEGER NOT NULL,
                stock INTEGER NOT NULL,
                created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
              );
            ''');
            await customStatement('''
              INSERT INTO products_new (
                id, name, buying_price, selling_price, stock, created_at, updated_at
              )
              SELECT
                id,
                name,
                CAST(ROUND(buying_price * 100.0) AS INTEGER),
                CAST(ROUND(selling_price * 100.0) AS INTEGER),
                stock,
                created_at,
                updated_at
              FROM products;
            ''');
            await customStatement('DROP TABLE products;');
            await customStatement('ALTER TABLE products_new RENAME TO products;');
          }
          if (from < 4) {
            await customStatement('''
              CREATE TABLE products_new (
                id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NULL REFERENCES users (id) ON DELETE CASCADE,
                name TEXT NOT NULL,
                buying_price INTEGER NOT NULL,
                selling_price INTEGER NOT NULL,
                stock INTEGER NOT NULL,
                created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
                updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
              );
            ''');
            await customStatement('''
              INSERT INTO products_new (
                id, user_id, name, buying_price, selling_price, stock, created_at, updated_at
              )
              SELECT
                p.id,
                (SELECT s.user_id FROM session s WHERE s.id = 1),
                p.name,
                p.buying_price,
                p.selling_price,
                p.stock,
                p.created_at,
                p.updated_at
              FROM products p;
            ''');
            await customStatement('DROP TABLE products;');
            await customStatement('ALTER TABLE products_new RENAME TO products;');
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'inventory.db'));
    return NativeDatabase(file);
  });
}
