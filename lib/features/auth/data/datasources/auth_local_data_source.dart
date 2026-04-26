import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';

/// Data source is the only layer that talks to Drift tables for auth.
class AuthLocalDataSource {
  AuthLocalDataSource(this._db);

  final AppDatabase _db;

  Future<User> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final id = await _db.into(_db.users).insert(
          UsersCompanion.insert(name: name, email: email, password: password),
        );
    return (_db.select(_db.users)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<User> createUserAndSaveSession({
    required String name,
    required String email,
    required String password,
  }) async {
    return _db.transaction(() async {
      final id = await _db.into(_db.users).insert(
            UsersCompanion.insert(name: name, email: email, password: password),
          );
      await _db.into(_db.session).insertOnConflictUpdate(
            SessionCompanion.insert(userId: Value(id)),
          );
      return (_db.select(_db.users)..where((t) => t.id.equals(id))).getSingle();
    });
  }

  Future<User?> getUserByEmail(String email) {
    return (_db.select(_db.users)..where((t) => t.email.equals(email))).getSingleOrNull();
  }

  Future<User?> getUserById(int userId) {
    return (_db.select(_db.users)..where((t) => t.id.equals(userId))).getSingleOrNull();
  }

  Future<void> saveSession(int? userId) {
    return _db.into(_db.session).insertOnConflictUpdate(
          SessionCompanion.insert(userId: Value(userId)),
        );
  }

  Future<int?> readSessionUserId() async {
    final row = await (_db.select(_db.session)..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.userId;
  }
}
