import 'datasources/auth_local_data_source.dart';
import '../../../core/security/password_hasher.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._local, this._hasher);

  final AuthLocalDataSource _local;
  final PasswordHasher _hasher;

  @override
  Future<AppUser?> getCurrentUser() async {
    final userId = await _local.readSessionUserId();
    if (userId == null) return null;
    final row = await _local.getUserById(userId);
    if (row == null) return null;
    return AppUser(id: row.id, name: row.name, email: row.email);
  }

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    final row = await _local.getUserByEmail(email);
    if (row == null) return null;
    final ok = _hasher.verify(plainPassword: password, storedValue: row.password);
    if (!ok) return null;
    await _local.saveSession(row.id);
    return AppUser(id: row.id, name: row.name, email: row.email);
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final hashedPassword = _hasher.hash(password);
    final row = await _local.createUserAndSaveSession(
      name: name,
      email: email,
      password: hashedPassword,
    );
    return AppUser(id: row.id, name: row.name, email: row.email);
  }

  @override
  Future<void> signOut() => _local.saveSession(null);
}
