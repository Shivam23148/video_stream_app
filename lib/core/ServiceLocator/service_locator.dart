import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ntavideofeedapp/core/dio_client/dio_client.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';

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

  serviceLocator.registerLazySingleton<DioClient>(() => DioClient());
}
