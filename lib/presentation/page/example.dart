import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/core/Utils/language_enum.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/localization/language_change_controller.dart';
import 'package:ntavideofeedapp/core/dio_client/dio_client.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:ntavideofeedapp/presentation/page/login_screen.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_example.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}


class _ExampleState extends State<Example> {
  String? _userInfo;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Example Screen"),
        actions: [
          Consumer<LanguageChangeController>(
            builder: (context, provider, child) {
              return PopupMenuButton(
                onSelected: (Language item) {
                  if (Language.english.name == item.name) {
                    provider.changeLanguage(Locale('en'));
                  } else {
                    logger.d("Hindi button pressed");
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
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Text("Login"),
          ),
          ElevatedButton(onPressed: () {}, child: Text("Register")),
        ],
      ),
    );
  }
}
