import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/device_list/data/services/Api_Call_Test.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/main/presentation/cubit/navigator_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ntavideofeedapp/core/dio_client/dio_client.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupLocator() async {
  serviceLocator.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );
  serviceLocator.registerLazySingleton<FlutterAppAuth>(() => FlutterAppAuth());
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton<DeviceFlowAuthService>(
    () => DeviceFlowAuthService(),
  );
  serviceLocator.registerLazySingleton(() => ApiService());

  serviceLocator.registerLazySingleton<DioClient>(() => DioClient());
  //Bloc
  //splash Bloc

  serviceLocator.registerLazySingleton<SplashBloc>(
    () => SplashBloc(serviceLocator<DeviceFlowAuthService>()),
  );

  //Auth Bloc

  serviceLocator.registerLazySingleton(
    () => AuthBloc(serviceLocator<DeviceFlowAuthService>()),
  );
  //Cubit
  //Main Cubit
  serviceLocator.registerLazySingleton(() => NavigatorCubit());
  serviceLocator.registerLazySingleton(() => NavbarCubit());
}
