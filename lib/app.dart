import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/di/injection.dart';
import 'core/l10n/app_strings.dart';
import 'core/l10n/language_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_signup_page.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/product/presentation/pages/home_page.dart';

void runInventoryApp() {
  configureDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LanguageCubit>()),
        BlocProvider(create: (_) => sl<AuthBloc>()..add(AuthStarted())),
        BlocProvider(create: (_) => sl<ProductBloc>()),
      ],
      child: const InventoryApp(),
    ),
  );
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (_, locale) {
        final appTitle = AppStrings.values[locale.languageCode]!['appTitle']!;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: appTitle,
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('bn')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.dark,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (_, state) {
              if (state.status == AuthStatus.authenticated) {
                return HomePage(
                  onSignOut: () {
                    context.read<ProductBloc>().add(ProductStateReset());
                    context.read<AuthBloc>().add(AuthSignOutRequested());
                  },
                );
              }
              return const LoginSignupPage();
            },
          ),
        );
      },
    );
  }
}
