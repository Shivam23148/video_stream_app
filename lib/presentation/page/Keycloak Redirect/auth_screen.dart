import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/core/ServiceLocator/service_locator.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final auth = serviceLocator<DeviceFlowAuthService>();
  String? userCode;
  String? verificationUrl;
  String? qrcode;
  String? token;
  bool authenticating = false;

  Future<void> startLogin() async {
    setState(() {
      authenticating = true;
    });
    try {
      print("Requesting device token");
      final deviceData = await auth.requestDeviceCode();
      print("device data from auth screen is :$deviceData");
      setState(() {
        userCode = deviceData['user_code'];
        verificationUrl = deviceData['verification_uri'];
        qrcode = deviceData['verification_uri_complete'];
        authenticating = false;
      });
      final tokenData = await auth.pollForToken(
        deviceData['device_code'],
        deviceData['interval'] ?? 5,
      );
      setState(() {
        token = tokenData['access_token'];
        authenticating = false;
      });
    } catch (e) {
      setState(() {
        authenticating = false;
      });
      print("Login Auth Screen Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: authenticating
          ? Center(child: CircularProgressIndicator())
          : token != null
          ? Column(
              children: [
                Text("Logged in!\nAccess Token:\n$token"),
                ElevatedButton(
                  onPressed: auth.getAccessToken,
                  child: Text("Access token"),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startLogin,
                  child: Text("Login with device code"),
                ),
                if (userCode != null) ...[
                  SizedBox(height: 16),
                  Text('Go to: $verificationUrl'),
                  Text('Enter code: $userCode'),
                  SizedBox(height: 16),
                  if (qrcode != null) QrImageView(data: qrcode!, size: 200),
                ],
              ],
            ),
    );
  }
}
