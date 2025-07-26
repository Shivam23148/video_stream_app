import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/core/Utils/language_enum.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/localization/language_change_controller.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:ntavideofeedapp/presentation/page/example.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/auth_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = serviceLocator<AuthService>();
  void _handleLogout(BuildContext context) async {
    await authService.logout();
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.loginRoute,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Consumer<LanguageChangeController>(
            builder: (context, provider, child) {
              return PopupMenuButton(
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provider.changeLanguage(Locale('en'));
                  } else {
                    logger.i("Hindi button pressed");
                    provider.changeLanguage(Locale('hi'));
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<Language>>[
                      const PopupMenuItem(
                        value: Language.english,
                        child: Text("English"),
                      ),
                      const PopupMenuItem(
                        value: Language.hindi,
                        child: Text("Hindi"),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleLogout(context),
          child: Text("Logout"),
        ),
      ),
    );
  }
}
