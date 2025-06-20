import 'package:dio/dio.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ntavideofeedapp/model/token_model.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();
  final String clientId = 'flutter_app_client';
  final String redirectUrl = 'com.example.ntavideofeedapp://oauthredirect';
  final String issuer = 'https://euc1.auth.ac/auth/realms/bitvividkeytest';

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
