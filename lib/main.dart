import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntavideofeedapp/core/ServiceLocator/service_locator.dart';
import 'package:ntavideofeedapp/core/controller/language_change_controller.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/example.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ntavideofeedapp/core/l10n/app_localizations.dart';
import 'package:ntavideofeedapp/core/routes/route_generator.dart';
import 'package:ntavideofeedapp/core/routes/route_names.dart';
import 'package:ntavideofeedapp/service/notification_service.dart';
import 'package:ntfluttery/ntfluttery.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await NotificationService().configuration();
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? '';
  runApp(MyApp(local: languageCode));
}

class MyApp extends StatelessWidget {
  final String local;
  const MyApp({super.key, required this.local});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final controller = LanguageChangeController();
            if (local.isNotEmpty) {
              controller.changeLanguage(Locale(local));
            } else {
              controller.changeLanguage(Locale('en'));
            }
            return controller;
          },
        ),
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {
          if (local.isEmpty) {
            provider.changeLanguage(Locale('en'));
          }
          return MaterialApp(
            title: 'Flutter Demo',
            locale: provider.appLocale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale("en"), Locale("hi")],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),
            initialRoute: Routes.splashRoute,
            onGenerateRoute: RouteGenerator.generateRoute,
          );

          // return MaterialApp(title: "Flutter App", home: ExampleScreen());
        },
      ),
    );
  }
}
