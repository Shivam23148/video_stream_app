import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ntavideofeedapp/ServiceLocator/service_locator.dart';
import 'package:ntavideofeedapp/Utils/global_variable.dart';
import 'package:ntavideofeedapp/model/token_model.dart';
import 'package:http/http.dart' as http;
/* 
class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();
  final String clientId = 'flutter_app_client';
  final String redirectUrl = 'com.example.ntavideofeedapp://oauthredirect';
  final String issuer = 'https://euc1.aut'h.ac/auth/realms/bitvividkeytest';

  final AuthorizationServiceConfiguration
  _serviceConfiguration = AuthorizationServiceConfiguration(
    authorizationEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/auth',
    tokenEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/token',
    endSessionEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/logout',
  );

  /* Future<bool> login() async {
    print("=== LOGIN START ===");

    // 1. Check if tokens are already stored and try to refresh if possible
    final refreshToken = await _flutterSecureStorage.read(key: 'refresh_token');
    final accessToken = await _flutterSecureStorage.read(
      key: 'access_token',
    ); // Also check access token

    if (accessToken != null && refreshToken != null) {
      print(
        "Found existing access and refresh tokens. Attempting to refresh...",
      );
      try {
        final refreshedTokenResult = await _appAuth.token(
          TokenRequest(
            clientId,
            redirectUrl,
            refreshToken: refreshToken,
            issuer: issuer,
            scopes: ['openid', 'profile' /*, 'offline_access'*/],
            serviceConfiguration: _serviceConfiguration,
          ),
        );

        if (refreshedTokenResult?.accessToken != null) {
          await _saveTokens(refreshedTokenResult!);
          print("Tokens refreshed successfully. User is logged in.");
          return true;
        }
      } catch (e) {
        print("Failed to refresh token silently: $e");
        // If refresh fails, tokens might be expired or revoked.
        // Proceed to interactive login.
        await _flutterSecureStorage
            .deleteAll(); // Clear potentially stale tokens
      }
    } else if (accessToken != null) {
      // This case handles if only access token is found but no refresh token
      // If the access token is still valid, user might still be logged in.
      // However, without a refresh token, this state won't last.
      // For simplicity, let's treat this as needing a full login if refresh isn't possible.
      print(
        "Found only access token, no refresh token. Proceeding to full login.",
      );
      await _flutterSecureStorage.delete(
        key: 'access_token',
      ); // Clear it to force full login
    }

    // 2. If no valid existing session or refresh failed, initiate full interactive login
    print(
      "No valid existing session or silent refresh failed. Initiating full interactive login...",
    );
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile' /*, 'offline_access'*/],
          serviceConfiguration: _serviceConfiguration,
          // preferEphemeralSession: false, // Consider setting this to false for better session persistence on iOS
        ),
      );

      if (result?.accessToken != null) {
        await _saveTokens(result!);
        print("Full login successful, tokens saved.");
        return true;
      } else {
        print("Full login result did not contain access token.");
        return false;
      }
    } catch (e, stacktrace) {
      print("Full login failed: $e");
      print(stacktrace);
      // It's crucial to handle specific AppAuth errors here.
      // For instance, if user cancels the login, it will throw an error.
      // You might want to return false without showing a general "failed" message.
      if (e.toString().contains("The operation couldn’t be completed")) {
        // Example for iOS user cancellation
        print("User cancelled login or a known platform error occurred.");
      }
      return false;
    } finally {
      print("=== LOGIN END ===");
    }
  }
 */

  Future<bool> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          serviceConfiguration: _serviceConfiguration,
        ),
      );

      /* if (result != null) {
        await _saveTokens(result);

        print("ACCESS TOKEN CLAIMS: ${JwtDecoder.decode(result.accessToken!)}");
        print(
          "ID TOKEN CLAIMS: ${result.idToken != null ? JwtDecoder.decode(result.idToken!) : 'NONE'}",
        );

        return true;
      } */
      if (result != null && result.accessToken != null) {
        await _saveTokensFromResponse(result);

        final accessTokenDecoded = JwtDecoder.decode(result.accessToken!);
        final idTokenDecoded = result.idToken != null
            ? JwtDecoder.decode(result.idToken!)
            : {};

        print("Access Token Claims: $accessTokenDecoded");
        print("ID Token Claims: $idTokenDecoded");

        return true;
      }
      return false;
    } catch (e, stack) {
      print("LOGIN ERROR: $e");
      print(stack);
      return false;
    }
  }

  Future<TokenModel?> getStoredTokens() async {
    final map = {
      'access_token': await _flutterSecureStorage.read(key: 'access_token'),
      'refresh_token': await _flutterSecureStorage.read(key: 'refresh_token'),
      'access_token_expiry': await _flutterSecureStorage.read(
        key: 'access_token_expiry',
      ),
      'refresh_token_expiry': await _flutterSecureStorage.read(
        key: 'refresh_token_expiry',
      ),
    };

    if (map.values.any((v) => v == null)) return null;
    return TokenModel.fromMap(map);
  }

  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      final response = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          refreshToken: refreshToken,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          serviceConfiguration: _serviceConfiguration,
        ),
      );
      if (response.accessToken != null) {
        return await _saveTokensFromResponse(
          response,
          fallbackRefreshToken: refreshToken,
        );
      }
    } catch (e) {
      print("Token refresh failed: $e");
    }
    return null;
  }

  Future<void> debugSessionStatus() async {
    final accessToken = await _flutterSecureStorage.read(key: 'access_token');
    if (accessToken == null) {
      print("No access token found");
      return;
    }

    final dio = Dio();

    try {
      final response = await dio.get(
        _serviceConfiguration.tokenEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      print("Session active: ${response.statusCode == 200}");
      print("Token introspection: ${response.data}");
    } on DioException catch (e) {
      print("Session check failed. Error: ${e.message}");
      if (e.response != null) {
        print("Status code: ${e.response!.statusCode}");
        print("Error response: ${e.response!.data}");
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
  }

  Future<String?> _saveTokensFromResponse(
    TokenResponse response, {
    String? fallbackRefreshToken,
  }) async {
    final accessToken = response.accessToken!;
    final refreshToken = response.refreshToken ?? fallbackRefreshToken ?? '';

    final accessTokenExpiry = JwtDecoder.getExpirationDate(accessToken);

    late DateTime refreshTokenExpiry;
    try {
      refreshTokenExpiry = JwtDecoder.getExpirationDate(refreshToken);
    } catch (_) {
      // If it's not a JWT or decoding fails, fall back
      refreshTokenExpiry = DateTime.now().add(const Duration(days: 30));
    }

    final tokenModel = TokenModel(
      accessToken,
      refreshToken,
      accessTokenExpiry,
      refreshTokenExpiry,
    );

    await _flutterSecureStorage.write(
      key: 'access_token',
      value: tokenModel.accessToken,
    );
    await _flutterSecureStorage.write(
      key: 'refresh_token',
      value: tokenModel.refreshToken,
    );
    await _flutterSecureStorage.write(
      key: 'access_token_expiry',
      value: tokenModel.accessTokenExpiry.toIso8601String(),
    );
    await _flutterSecureStorage.write(
      key: 'refresh_token_expiry',
      value: tokenModel.refreshTokenExpiry.toIso8601String(),
    );
    if (response.idToken != null) {
      await _flutterSecureStorage.write(
        key: 'id_token',
        value: response.idToken,
      );
    }

    return accessToken;
  }

  // Helper method to save tokens
  Future<void> _saveTokens(TokenModel token) async {
    final map = token.toMap();
    for (var i in map.entries) {
      await _flutterSecureStorage.write(key: i.key, value: i.value);
    }
  }

  // Your existing logout and getUserInfo methods
  Future<void> logout() async {
    print("=== LOGOUT START ===");
    final idToken = await _flutterSecureStorage.read(key: 'id_token');
    print("ID Token before logout: $idToken");

    if (idToken != null && idToken.isNotEmpty) {
      try {
        print("Calling endSession endpoint...");
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl:
                redirectUrl, // Ensure this is also configured in Keycloak as a valid post-logout redirect URI
            issuer: issuer,
            serviceConfiguration:
                _serviceConfiguration, // Use the shared service config
          ),
        );
        print("EndSession request completed.");
      } catch (e, stacktrace) {
        print('Error during logout: $e');
        print(stacktrace);
      }
    } else {
      print('No ID token found; skipping end session request.');
    }

    await _flutterSecureStorage.deleteAll();
    print("Cleared stored tokens.");
    print("=== LOGOUT END ===");
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final idToken = await _flutterSecureStorage.read(key: 'id_token');
    if (idToken == null) {
      print("No ID token found for getUserInfo.");
      return {}; // Or throw an error
    }
    print("Decoding ID token: $idToken");
    return JwtDecoder.decode(idToken);
  }
}
 */

class AuthService {
  final FlutterAppAuth appAuth = serviceLocator<FlutterAppAuth>();
  final FlutterSecureStorage secureStorage =
      serviceLocator<FlutterSecureStorage>();

  final String client_id = 'flutter_app_client';
  final redirectUrl = "com.example.ntavideofeedapp://oauthredirect";
  final String issuer = "https://euc1.auth.ac/auth/realms/bitvividkeytest";

  final AuthorizationServiceConfiguration
  _serviceConfiguration = AuthorizationServiceConfiguration(
    authorizationEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/auth',
    tokenEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/token',
    endSessionEndpoint:
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/logout',
  );

  Future<bool> login() async {
    try {
      print("login started");
      final result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          client_id,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          clientSecret: "IwM0EgVNyuK4mkmC9UY96hXPPBCHDNK7",
          serviceConfiguration: _serviceConfiguration,
        ),
      );

      if (result != null && result.accessToken != null) {
        print("Result is ${result.toString()}");
        await secureStorage.write(
          key: 'access_token',
          value: result.accessToken,
        );
        final expiry = DateTime.now().add(
          Duration(
            seconds:
                result.accessTokenExpirationDateTime
                    ?.difference(DateTime.now())
                    .inSeconds ??
                300,
          ),
        );

        await secureStorage.write(
          key: 'access_token_expiry',
          value: expiry.toIso8601String(),
        );

        await secureStorage.write(
          key: 'refresh_token',
          value: result.refreshToken,
        );
        await secureStorage.write(key: 'id_token', value: result.idToken ?? '');
        await getRole();
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: ${e.toString()}");
      return false;
    }
  }

  Future<void> getRole() async {
    print("Role fetching start");
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null || !accessToken.contains('.')) {
      print("Invalid or null token");
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    final roles = decodedToken['realm_access']['roles'] ?? [];

    if (roles.contains('user_admin')) {
      GlobalUse.userRole = 'Admin';
    } else if (roles.contains('field_officer')) {
      GlobalUse.userRole = 'Field Officer';
    } else if (roles.contains('analyst')) {
      GlobalUse.userRole = 'analyst';
    }
  }

  Future<void> logout() async {
    final idToken = await secureStorage.read(key: 'id_token');
    if (idToken != null && idToken.isNotEmpty) {
      try {
        await appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: redirectUrl,
            issuer: issuer,
            serviceConfiguration: _serviceConfiguration,
          ),
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    await secureStorage.deleteAll();
  }

  Future<bool> isLoginStatus() async {
    try {
      final accessToken = await secureStorage.read(key: 'access_token');

      if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Login Status error: ${e}");
      return false;
    }
  }

  bool _isAccessTokenExpired(String expiryIsoString) {
    final expiry = DateTime.parse(expiryIsoString);
    return DateTime.now().isAfter(
      expiry.subtract(const Duration(minutes: 1)),
    ); // buffer of 1 min
  }

  /* Future<String?> refreshAccessTokenIfNeeded() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    final accessTokenExpiry = await secureStorage.read(
      key: 'access_token_expiry',
    );

    if (accessToken == null ||
        refreshToken == null ||
        accessTokenExpiry == null) {
      return null;
    }

    if (!_isAccessTokenExpired(accessTokenExpiry)) {
      return accessToken; // still valid
    }

    try {
      final response = await appAuth.token(
        TokenRequest(
          client_id,
          redirectUrl,
          refreshToken: refreshToken,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          serviceConfiguration: _serviceConfiguration,
        ),
      );

      if (response != null && response.accessToken != null) {
        final newAccessToken = response.accessToken!;
        final newAccessTokenExpiry = DateTime.now().add(
          Duration(
            seconds:
                response.accessTokenExpirationDateTime
                    ?.difference(DateTime.now())
                    .inSeconds ??
                300,
          ),
        );

        await secureStorage.write(key: 'access_token', value: newAccessToken);
        await secureStorage.write(
          key: 'access_token_expiry',
          value: newAccessTokenExpiry.toIso8601String(),
        );

        if (response.refreshToken != null) {
          await secureStorage.write(
            key: 'refresh_token',
            value: response.refreshToken,
          );
        }

        return newAccessToken;
      }
    } catch (e) {
      print("Token refresh failed: $e");
    }

    return null;
  }
 */
}

class DeviceFlowAuthService {
  final FlutterSecureStorage secureStorage =
      serviceLocator<FlutterSecureStorage>();
  final String clientId = 'flutter_app_client';
  final String realm = 'bitvividkeytest';
  final String keycloakBaseUrl = 'https://euc1.auth.ac/auth';

  /* late final Dio dioClient;
  DeviceFlowAuthService() {
    dioClient = Dio(
      BaseOptions(
        baseUrl: '$keycloakBaseUrl/realms/$realm/protocol/openid-connect',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      ),
    );

    dioClient.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    ); 
  }*/

  Uri get deviceCodeUrl => Uri.parse(
    '$keycloakBaseUrl/realms/$realm/protocol/openid-connect/auth/device',
  );

  Uri get tokenUrl =>
      Uri.parse('$keycloakBaseUrl/realms/$realm/protocol/openid-connect/token');
  //Request device token
  Future<Map<String, dynamic>> requestDeviceCode() async {
    final response = await http.post(
      deviceCodeUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'client_id': clientId, 'scope': 'openid offline_access'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to request device code: ${response.body}');
    }
  }

  //Poll for token using device code using Dio
  /* Future<Map<String, dynamic>> pollforToken(
    String deviceCode,
    int interval,
  ) async {
    while (true) {
      await Future.delayed(Duration(seconds: interval));
      try {
        final response = await dioClient.post(
          '/token',
          data: {
            'grant_type': 'urn:ietf:param:oauth:grant-type:device_code',
            'device_code': deviceCode,
            'client_id': clientId,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        if (response.statusCode == 200 &&
            response.data['access_token'] != null) {
          await secureStorage.write(
            key: 'access_token',
            value: response.data['access_token'],
          );
          await secureStorage.write(
            key: 'refresh_token',
            value: response.data['refresh_token'],
          );
          return response.data;
        } else if (response.data['error'] == 'authorization_pending') {
          continue;
        } else {
          throw Exception("Authorization failed: ${response.data['error']}");
        }
      } catch (e) {
        throw Exception('Token polling failed: $e');
      }
    }
  }
 */
  //Poll for token using device code using Http
  Future<Map<String, dynamic>> pollForToken(
    String deviceCode,
    int interval,
  ) async {
    while (true) {
      await Future.delayed(Duration(seconds: interval));
      final response = await http.post(
        tokenUrl,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
          'device_code': deviceCode,
          'client_id': clientId,
        },
      );
      final data = jsonDecode(response.body);
      print("Polling response is :$data");
      if (response.statusCode == 200) {
        await secureStorage.write(
          key: 'access_token',
          value: data['access_token'],
        );
        await secureStorage.write(
          key: 'refresh_token',
          value: data['refresh_token'],
        );
        return data;
      }
      if (data['error'] == 'authorization_pending') {
        continue;
      } else {
        throw Exception('Polling failed: ${data['error']}');
      }
    }
  }

  Future<String?> refreshAccessToken() async {
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    if (refreshToken == null) return null;
    print("Token Refreshed Auth Service: $refreshToken");
    final response = await http.post(
      tokenUrl,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        'client_id': clientId,
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await secureStorage.write(
        key: 'access_token',
        value: data['access_token'],
      );
      if (data['refresh_token'] != null) {
        await secureStorage.write(
          key: 'refresh_token',
          value: data['refresh_token'],
        );
      }
      return data["access_token"];
    } else {
      await secureStorage.deleteAll();
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    print("Access Token from auth service: $accessToken");
    return accessToken;
  }

  Future<void> getRole() async {
    print("Role fetching start");
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null || !accessToken.contains('.')) {
      print("Invalid or null token");
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    final roles = decodedToken['realm_access']['roles'] ?? [];
    print("Role fetched auth service: $roles");

    if (roles.contains('user_admin')) {
      GlobalUse.userRole = 'Admin';
    } else if (roles.contains('field_officer')) {
      GlobalUse.userRole = 'Field Officer';
    } else if (roles.contains('analyst')) {
      GlobalUse.userRole = 'analyst';
    }
  }

  Future<String?> getValidAccessToken() async {
    final accessToken = await secureStorage.read(key: 'access_token');

    if (accessToken == null || JwtDecoder.isExpired(accessToken)) {
      print("Access token expired. Attempting to refresh...");
      return await refreshAccessToken(); // Refresh token method already in your code
    }

    return accessToken;
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
  }
}
