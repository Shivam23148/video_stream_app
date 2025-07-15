import 'package:dio/dio.dart';
import 'package:ntavideofeedapp/main.dart';

class CustomLoginterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('Request[${options.method}]=> PATH: ${options.path}');
    logger.d('Headers: ${options.headers}');
    logger.d('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
      'Response[${response.statusCode}] => PATH: ${response.requestOptions}',
    );
    logger.d('Response data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      'Error [${err.response?.statusCode}] => ${err.requestOptions.path}',
    );
    logger.e('Message: ${err.message}');
    logger.d('Response: ${err.response?.data}');
    handler.next(err);
  }
}
