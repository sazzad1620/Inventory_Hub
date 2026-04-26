import '../../../../core/errors/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  GetCurrentUserUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AppUser?>> call() async {
    try {
      return Success(await _repo.getCurrentUser());
    } catch (e) {
      return FailureResult(
        'Failed to read session',
        code: 'session_read_failed',
      );
    }
  }
}

class SignInUseCase {
  SignInUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _repo.signIn(email: email, password: password);
      if (user == null) {
        return const FailureResult(
          'Invalid credentials',
          code: 'invalid_credentials',
        );
      }
      return Success(user);
    } catch (e) {
      return const FailureResult(
        'Sign-in failed',
        code: 'signin_failed',
      );
    }
  }
}

class SignUpUseCase {
  SignUpUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<AppUser>> call({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      return Success(await _repo.signUp(name: name, email: email, password: password));
    } catch (e) {
      return const FailureResult('Signup failed', code: 'signup_failed');
    }
  }
}

class SignOutUseCase {
  SignOutUseCase(this._repo);
  final AuthRepository _repo;

  Future<Result<void>> call() async {
    try {
      await _repo.signOut();
      return const Success(null);
    } catch (e) {
      return FailureResult(
        'Sign-out failed',
        code: 'signout_failed',
      );
    }
  }
}
