import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/result.dart';
import 'package:inventory_management_app/features/auth/domain/entities/app_user.dart';
import 'package:inventory_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:inventory_management_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:inventory_management_app/features/auth/presentation/bloc/auth_bloc.dart';

class _NoopAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    return null;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}

class _FakeGetCurrentUserUseCase extends GetCurrentUserUseCase {
  _FakeGetCurrentUserUseCase() : super(_NoopAuthRepository());

  @override
  Future<Result<AppUser?>> call() async => const Success(null);
}

class _FakeSignInSuccessUseCase extends SignInUseCase {
  _FakeSignInSuccessUseCase() : super(_NoopAuthRepository());

  @override
  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    return const Success(AppUser(id: 1, name: 'Owner', email: 'owner@grocery.com'));
  }
}

class _FakeSignInInvalidUseCase extends SignInUseCase {
  _FakeSignInInvalidUseCase() : super(_NoopAuthRepository());

  @override
  Future<Result<AppUser>> call({
    required String email,
    required String password,
  }) async {
    return const FailureResult('Invalid credentials', code: 'invalid_credentials');
  }
}

class _FakeSignUpUseCase extends SignUpUseCase {
  _FakeSignUpUseCase() : super(_NoopAuthRepository());
}

class _FakeSignOutUseCase extends SignOutUseCase {
  _FakeSignOutUseCase() : super(_NoopAuthRepository());
}

void main() {
  blocTest<AuthBloc, AuthState>(
    'emits loading then authenticated on successful sign-in',
    build: () => AuthBloc(
      getCurrentUser: _FakeGetCurrentUserUseCase(),
      signIn: _FakeSignInSuccessUseCase(),
      signUp: _FakeSignUpUseCase(),
      signOut: _FakeSignOutUseCase(),
    ),
    act: (bloc) => bloc.add(const AuthSignInRequested(email: 'owner@grocery.com', password: '123456')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(id: 1, name: 'Owner', email: 'owner@grocery.com'),
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits loading then unauthenticated with invalid_credentials',
    build: () => AuthBloc(
      getCurrentUser: _FakeGetCurrentUserUseCase(),
      signIn: _FakeSignInInvalidUseCase(),
      signUp: _FakeSignUpUseCase(),
      signOut: _FakeSignOutUseCase(),
    ),
    act: (bloc) => bloc.add(const AuthSignInRequested(email: 'owner@grocery.com', password: 'bad')),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.unauthenticated, error: 'invalid_credentials'),
    ],
  );
}
