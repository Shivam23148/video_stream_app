import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_example.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService = serviceLocator<AuthService>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  bool success = await authService.login();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login Completed')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login failed')),
                    );
                  }
                },
                child: const Text('Login with Keycloak'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  print("Logout button pressed");
                  await authService.logout();
                  print("Logout process completed");
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
