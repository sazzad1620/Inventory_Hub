import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/language_cubit.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/language_switcher.dart';
import '../bloc/auth_bloc.dart';

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        final t = AppStrings.values[locale.languageCode]!;
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A0A0A), Color(0xFF121212), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppLogo(size: 96, borderRadius: 10),
                            const SizedBox(height: 12),
                            Text(t['appTitle']!, style: const TextStyle(fontSize: 32, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text(t['subtitle']!, style: const TextStyle(color: Color(0xFF9CA3AF))),
                            const SizedBox(height: 26),
                            if (_isSignUp) ...[
                              TextFormField(
                                controller: _name,
                                decoration: InputDecoration(labelText: t['name']),
                                validator: (v) => (v == null || v.isEmpty) ? t['requiredField'] : null,
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: _email,
                              decoration: InputDecoration(
                                labelText: t['email'],
                                hintText: t['emailPlaceholder'],
                              ),
                              validator: (v) => (v == null || !v.contains('@')) ? t['invalidEmail'] : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              decoration: InputDecoration(
                                labelText: t['password'],
                                hintText: t['passwordPlaceholder'],
                              ),
                              obscureText: true,
                              validator: (v) => (v == null || v.length < 6) ? t['minPassword'] : null,
                            ),
                            if (_isSignUp) ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _confirm,
                                decoration: InputDecoration(labelText: t['confirmPassword']),
                                obscureText: true,
                                validator: (v) => v != _password.text ? t['passwordMismatch'] : null,
                              ),
                            ],
                            const SizedBox(height: 22),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (_, state) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: state.status == AuthStatus.loading ? null : _submit,
                                    child: Text(_isSignUp ? t['signUp']! : t['signIn']!),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => setState(() => _isSignUp = !_isSignUp),
                              child: Text(_isSignUp ? t['switchToSignIn']! : t['switchToSignUp']!),
                            ),
                            const LanguageSwitcher(),
                            const SizedBox(height: 10),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (_, state) {
                                if (state.error == null) return const SizedBox.shrink();
                                final isInvalidCredentials = state.error == 'invalid_credentials';
                                return Text(
                                  isInvalidCredentials ? t['invalidCredentials']! : t['authActionFailed']!,
                                  style: const TextStyle(color: Colors.redAccent),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_isSignUp) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(name: _name.text.trim(), email: _email.text.trim(), password: _password.text.trim()),
          );
    } else {
      context.read<AuthBloc>().add(AuthSignInRequested(email: _email.text.trim(), password: _password.text.trim()));
    }
  }
}
