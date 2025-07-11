import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/localization/app_localizations.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';

class KeycloakAuthenticationRedirectScreen extends StatefulWidget {
  const KeycloakAuthenticationRedirectScreen({super.key});

  @override
  State<KeycloakAuthenticationRedirectScreen> createState() =>
      _KeycloakAuthenticationRedirectScreenState();
}

class _KeycloakAuthenticationRedirectScreenState
    extends State<KeycloakAuthenticationRedirectScreen> {
  final AuthService authService = serviceLocator<AuthService>();
  void _handleLogin(BuildContext context) async {
    final success = await authService.login();
    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login Completed')));
      Navigator.pushReplacementNamed(context, Routes.homeRoute);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () => _handleLogin(context),
                child: Text(AppLocalizations.of(context)!.signinToKC),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(AppLocalizations.of(context)!.registerToKC),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
