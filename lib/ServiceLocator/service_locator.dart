import 'package:get_it/get_it.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupLocator() async {
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
}
