/* 
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();
  final String clientId = 'flutter_app_client';
  final String redirectUrl = 'com.example.ntavideofeedapp://oauthredirect';
  final String issuer = 'https://euc1.auth.ac/auth/realms/bitvividkeytest';

  /*  Future<bool> login() async {
    print('Starting login');
    try {
      print('Sending authorization request to: $issuer');

      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile'],
          promptValues: ['none'],
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$issuer/protocol/openid-connect/auth',
            tokenEndpoint: '$issuer/protocol/openid-connect/token',
            endSessionEndpoint: '$issuer/protocol/openid-connect/logout',
          ),
          allowInsecureConnections: true,
        ),
      );

      print("Authorization successful. Access Token: ${result.accessToken}");
      await _flutterSecureStorage.write(
        key: 'access_token',
        value: result.accessToken,
      );
      await _flutterSecureStorage.write(
        key: 'refresh_token',
        value: result.refreshToken,
      );
      await _flutterSecureStorage.write(key: 'id_token', value: result.idToken);

      return true;
    } on PlatformException catch (e) {
      print(
        'PlatformException: code=${e.code}, message=${e.message}, details=${e.details}',
      );
      return false;
    } catch (e, stacktrace) {
      print('Unexpected error: $e\n$stacktrace');
      return false;
    }
  } */

  Future<bool> login() async {
    // 1. Check existing token
    final accessToken = await _flutterSecureStorage.read(key: 'access_token');
    if (accessToken != null) {
      print("Already logged in with existing access token");
      return true;
    }

    // 2. Try silent login
    try {
      print("Attempting silent login...");
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          promptValues: ['none'], // silent login
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$issuer/protocol/openid-connect/auth',
            tokenEndpoint: '$issuer/protocol/openid-connect/token',
            endSessionEndpoint: '$issuer/protocol/openid-connect/logout',
          ),
        ),
      );

      if (result?.authorizationCode != null) {
        final tokenResult = await _appAuth.token(
          TokenRequest(
            clientId,
            redirectUrl,
            authorizationCode: result.authorizationCode!,
            codeVerifier: result.codeVerifier!,
            issuer: issuer,
            scopes: ['openid', 'profile', 'offline_access'],
            serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: '$issuer/protocol/openid-connect/auth',
              tokenEndpoint: '$issuer/protocol/openid-connect/token',
              endSessionEndpoint: '$issuer/protocol/openid-connect/logout',
            ),
          ),
        );

        await _flutterSecureStorage.write(
          key: 'access_token',
          value: tokenResult.accessToken,
        );
        await _flutterSecureStorage.write(
          key: 'refresh_token',
          value: tokenResult.refreshToken,
        );
        await _flutterSecureStorage.write(
          key: 'id_token',
          value: tokenResult.idToken,
        );
        return true;
      }
    } catch (e) {
      print("Silent login failed: $e");
    }

    // 3. Full login as fallback
    try {
      print("Fallback: full login...");
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: issuer,
          scopes: ['openid', 'profile', 'offline_access'],
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: '$issuer/protocol/openid-connect/auth',
            tokenEndpoint: '$issuer/protocol/openid-connect/token',
            endSessionEndpoint: '$issuer/protocol/openid-connect/logout',
          ),
        ),
      );

      await _flutterSecureStorage.write(
        key: 'access_token',
        value: result.accessToken,
      );
      await _flutterSecureStorage.write(
        key: 'refresh_token',
        value: result.refreshToken,
      );
      await _flutterSecureStorage.write(key: 'id_token', value: result.idToken);

      return true;
    } catch (e) {
      print("Full login failed: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final idToken = await _flutterSecureStorage.read(key: 'id_token');

    if (idToken != null && idToken.isNotEmpty) {
      try {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: redirectUrl,
            issuer: issuer,
          ),
        );
      } catch (e) {
        print('Error during logout: $e');
      }
    } else {
      print('No ID token found; skipping end session request.');
    }

    await _flutterSecureStorage.deleteAll();
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final idToken = await _flutterSecureStorage.read(key: 'id_token');
    return JwtDecoder.decode(idToken!);
  }
}

 */
