import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_management_app/core/errors/result.dart';
import 'package:inventory_management_app/features/auth/domain/entities/app_user.dart';
import 'package:inventory_management_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:inventory_management_app/features/auth/domain/usecases/auth_usecases.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.signInResult});

  final AppUser? signInResult;

  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    return signInResult;
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

class _ThrowingAuthRepository implements AuthRepository {
  @override
  Future<AppUser?> getCurrentUser() async => null;

  @override
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    throw Exception('db error');
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

void main() {
  test('SignInUseCase returns Success with user on valid credentials', () async {
    final useCase = SignInUseCase(
      _FakeAuthRepository(signInResult: const AppUser(id: 1, name: 'Owner', email: 'owner@grocery.com')),
    );

    final result = await useCase(email: 'owner@grocery.com', password: '123456');

    expect(result, isA<Success<AppUser>>());
    expect((result as Success<AppUser>).data.email, 'owner@grocery.com');
  });

  test('SignInUseCase returns FailureResult on invalid credentials', () async {
    final useCase = SignInUseCase(_FakeAuthRepository(signInResult: null));

    final result = await useCase(email: 'owner@grocery.com', password: 'wrong');

    expect(result, isA<FailureResult<AppUser>>());
    expect((result as FailureResult<AppUser>).code, 'invalid_credentials');
  });

  test('SignInUseCase returns signin_failed on unexpected repository error', () async {
    final useCase = SignInUseCase(_ThrowingAuthRepository());

    final result = await useCase(email: 'owner@grocery.com', password: '123456');

    expect(result, isA<FailureResult<AppUser>>());
    expect((result as FailureResult<AppUser>).code, 'signin_failed');
  });
}
