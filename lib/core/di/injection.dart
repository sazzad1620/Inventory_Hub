import 'package:get_it/get_it.dart';

import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/product/data/datasources/product_local_data_source.dart';
import '../../features/product/data/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../database/app_database.dart';
import '../l10n/language_cubit.dart';
import '../security/password_hasher.dart';

final sl = GetIt.instance;

/// Simple DI setup to keep app wiring scalable.
void configureDependencies() {
  if (sl.isRegistered<AppDatabase>()) return;

  sl.registerLazySingleton(AppDatabase.new);
  sl.registerLazySingleton(() => const PasswordHasher());

  sl.registerLazySingleton(() => AuthLocalDataSource(sl()));
  sl.registerLazySingleton(() => ProductLocalDataSource(sl()));

  // Register by interface type so use-cases can request abstractions.
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(sl()));

  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));

  sl.registerFactory(LanguageCubit.new);
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
    ),
  );
  sl.registerFactory(
    () => ProductBloc(
      getProducts: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      deleteProduct: sl(),
    ),
  );
}
