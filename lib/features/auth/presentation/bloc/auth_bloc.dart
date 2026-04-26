import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/result.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/auth_usecases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
  })  : _getCurrentUser = getCurrentUser,
        _signIn = signIn,
        _signUp = signUp,
        _signOut = signOut,
        super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await _getCurrentUser();
    if (result is Success<AppUser?>) {
      final user = result.data;
      emit(state.copyWith(status: user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated, user: user));
      return;
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }

  Future<void> _onSignInRequested(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signIn(email: event.email, password: event.password);
    if (result is FailureResult<AppUser>) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, error: result.code ?? 'signin_failed'));
      return;
    }
    final user = (result as Success<AppUser>).data;
    emit(state.copyWith(status: AuthStatus.authenticated, user: user, clearError: true));
  }

  Future<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final result = await _signUp(name: event.name, email: event.email, password: event.password);
    if (result is Success<AppUser>) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: result.data));
      return;
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated, error: (result as FailureResult<AppUser>).code ?? 'signup_failed'));
  }

  Future<void> _onSignOutRequested(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    final result = await _signOut();
    if (result is FailureResult<void>) {
      emit(state.copyWith(error: result.code ?? 'signout_failed'));
      return;
    }
    emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true, clearError: true));
  }
}
