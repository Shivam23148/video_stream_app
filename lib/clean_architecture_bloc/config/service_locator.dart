import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/network/dio_client.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/data/data_sources/Api_Call_Test.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/data/respository/camera_respository_impl.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/respositories/camera_repository.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/domain/usecases/fetch_camera_usecase.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/device_list/presentation/bloc/device_list_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/main/presentation/cubit/navigator_cubit.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/auth_service.dart';

final serviceLocator = GetIt.instance;

Future<void> setupLocator() async {
  //Dio
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  //Dio Client
  serviceLocator.registerLazySingleton(DioClient.new);
  serviceLocator.registerLazySingleton<FlutterSecureStorage>(
    () => FlutterSecureStorage(),
  );
  serviceLocator.registerLazySingleton<FlutterAppAuth>(() => FlutterAppAuth());
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton<DeviceFlowAuthService>(
    () => DeviceFlowAuthService(),
  );
  serviceLocator.registerLazySingleton(() => ApiService(serviceLocator()));

  //Repository
  serviceLocator.registerLazySingleton<CameraRepository>(
    () => CameraRespositoryImpl(serviceLocator()),
  );

  //UseCase
  serviceLocator.registerLazySingleton(
    () => FetchCameraUsecase(serviceLocator()),
  );
  //Bloc

  //Device List
  serviceLocator.registerFactory(() => DeviceListBloc(serviceLocator()));
  //splash Bloc

  serviceLocator.registerFactory<SplashBloc>(
    () => SplashBloc(serviceLocator<DeviceFlowAuthService>()),
  );

  //Auth Bloc

  serviceLocator.registerFactory(
    () => AuthBloc(serviceLocator<DeviceFlowAuthService>()),
  );
  //Cubit
  //Main Cubit
  serviceLocator.registerLazySingleton(() => NavigatorCubit());
  serviceLocator.registerLazySingleton(() => NavbarCubit());
}
