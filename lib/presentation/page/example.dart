import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/controller/language_change_controller.dart';
import 'package:ntavideofeedapp/dio_client/dio_client.dart';
import 'package:ntavideofeedapp/presentation/page/login_screen.dart';
import 'package:ntavideofeedapp/service/auth_example.dart';
import 'package:ntavideofeedapp/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  State<Example> createState() => _ExampleState();
}

enum Language { english, hindi }

class _ExampleState extends State<Example> {
  final AuthService authService = AuthService();
  late DioClient dioClient;

  String? _userInfo;
  bool _isLoading = false;

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _userInfo = null;
    });

    try {
      final response = await dioClient.client.get(
        'https://euc1.auth.ac/auth/realms/bitvividkeytest/protocol/openid-connect/userinfo',
      );

      setState(() {
        _userInfo = response.data.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userInfo = " Failed to fetch user info: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerUrl =
        '${authService.issuer}/protocol/openid-connect/registrations?client_id=${authService.clientId}&response_type=code';

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
                    print("Hindi button pressed");
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
          ElevatedButton(
            onPressed: () {
              launchUrl(
                Uri.parse(registerUrl),
                mode: LaunchMode.externalApplication,
              );
            },
            child: Text("Register"),
          ),
        ],
      ),
    );
  }
}
