import 'package:dio/dio.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';

class DioClient {
  final Dio _dio = Dio();
  final AuthService authService;

  DioClient(this.authService) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final tokens = await authService.getStoredTokens();
          if (tokens != null && tokens.isAccessTokenValid) {
            options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final tokens = await authService.getStoredTokens();
            if (tokens != null && tokens.isRefreshTokenValid) {
              final newAccessToken = await authService.refreshAccessToken(
                tokens.refreshToken,
              );
              if (newAccessToken != null) {
                // Retry original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final cloneReq = await _dio.fetch(error.requestOptions);
                return handler.resolve(cloneReq);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get client => _dio;
}
