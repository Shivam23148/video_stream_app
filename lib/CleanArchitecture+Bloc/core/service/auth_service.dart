import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/core/Utils/global_variable.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:ntavideofeedapp/model/token_model.dart';
import 'package:http/http.dart' as http;

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
    logger.d(
      "Request Device Code inside Device Flow auth service: ${response.body} ",
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
      logger.d("Polling response is :$data");
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
    logger.d("Refresh token is from device flow auth service: $refreshToken");
    if (refreshToken == null) return null;
    logger.d("Token Refreshed Auth Service: $refreshToken");
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
    logger.d("Access Token from auth service: $accessToken");
    return accessToken;
  }

  Future<void> getRole() async {
    logger.i("Role fetching start");
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken == null || !accessToken.contains('.')) {
      logger.i("Invalid or null token");
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);

    final roles = decodedToken['realm_access']['roles'] ?? [];
    logger.d("Role fetched auth service: $roles");

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
      logger.i("Access token expired. Attempting to refresh");
      return await refreshAccessToken();
    }

    return accessToken;
  }

  Future<void> sendVerificationUrl({
    required String deviceCode,
    required String verificationUrl,
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("https://dc6b3f5bdfce.ngrok-free.app/send-device-code"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'deviceCode': deviceCode,
        'verificationUrl': verificationUrl,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send verification info: ${response.body}');
    }
  }

  Future<void> logout() async {
    await secureStorage.deleteAll();
  }
}
