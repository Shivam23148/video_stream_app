import 'package:dio/dio.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/shared/utils/custom_loginterceptor.dart';
import 'package:ntavideofeedapp/main.dart';

class DioClient {
  late final Dio _dio;
  DioClient()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          responseType: ResponseType.json,
        ),
      ) {
    _dio.interceptors.add(CustomLoginterceptor());
  }

  //Get
  Future<Response> get(
    String url, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  //Post
  Future<Response> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  //Put
  Future<Response> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  //Delete
  Future<Response> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: query,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    logger.e('DioException [${e.type}] - ${e.message}');
    if (e.response != null) {
      logger.e('Status Code: ${e.response?.statusCode}');
      logger.e('Response Data: ${e.response?.data}');
    }
  }
}
