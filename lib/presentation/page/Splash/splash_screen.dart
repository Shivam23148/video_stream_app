import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntavideofeedapp/ServiceLocator/service_locator.dart';
import 'package:ntavideofeedapp/dio_client/dio_client.dart';
import 'package:ntavideofeedapp/routes/route_names.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService authService = serviceLocator<AuthService>();
  final deviceFlowAuthService = serviceLocator<DeviceFlowAuthService>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    /* final accessToken = await deviceFlowAuthService.getAccessToken();
    print("Access Token Splash Screen: $accessToken");
    final token =
        accessToken ?? await deviceFlowAuthService.refreshAccessToken();
    print("Token Splash Screen : $token"); */
    final token = await deviceFlowAuthService.getValidAccessToken();
    if (token != null) {
      await deviceFlowAuthService.getRole();
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.homeRoute,
        (Route<dynamic> route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loginRoute,
        (Route<dynamic> route) => false,
      );
    }

    /* final isLoggedIn = await authService.isLoginStatus();

    if (isLoggedIn) {
      final dio = serviceLocator<DioClient>().client;
      try {
        final response = await dio.get('/userinfo');
        final userData = response.data;
        print("User infor : $userData");
        await authService.getRole();
        Navigator.pushNamed(context, Routes.homeRoute);
      } catch (e) {
        print("Failed to get user infor: ${e}");
        Navigator.pushNamed(context, Routes.loginRoute);
      }
    } else {
      Navigator.pushNamed(context, Routes.loginRoute);
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Text('Splash Screen')),
    );
  }
}
