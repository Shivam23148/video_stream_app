import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ntavideofeedapp/ServiceLocator/service_locator.dart';

class DioClient {
  final Dio dio = Dio();

  final FlutterSecureStorage flutterSecureStorage =
      serviceLocator<FlutterSecureStorage>();
  DioClient() {
    dio.options.baseUrl =
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (option, handler) async {
          final token = await flutterSecureStorage.read(key: 'access_token');
          if (token != null) {
            option.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(option);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );
  }
  Dio get client => dio;
}
