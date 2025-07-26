import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/localization/language_change_controller.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/Ntfy/background_task.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/theme/app_theme.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/shared/utils/snackbar_util.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/localization/app_localizations.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_generator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/service/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

var logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  printer: PrettyPrinter(),
);

void main() async {
  logger.i("App Started ");

  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  await NotificationService().configuration();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  /* Workmanager().registerPeriodicTask(
    "fetch_message_task_id",
    "fetch_message_task",
    frequency: Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: Constraints(networkType: NetworkType.connected),
  ); */
  Workmanager().registerOneOffTask(
    "test_task_id",
    "fetch_message_task", // this must match the name inside callbackDispatcher
    initialDelay: Duration(seconds: 10), // test delay
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? '';
  runApp(MyApp(local: languageCode));
}

class MyApp extends StatelessWidget {
  final String local;
  const MyApp({super.key, required this.local});

  @override
  Widget build(BuildContext context) {
    logger.i("App UI is Building");
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
          /*  logger.d(
            "App Current Langauge is ${Localizations.localeOf(context)}",
          ); */
          if (local.isEmpty) {
            provider.changeLanguage(Locale('en'));
          }
          Locale deviceLanguage = WidgetsBinding.instance.window.locale;
          logger.d("Device Language is $deviceLanguage");
          return MaterialApp(
            title: 'Flutter Demo',
            locale: provider.appLocale,

            scaffoldMessengerKey: SnackbarUtil.messangerKey,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale("en"), Locale("hi")],
            theme: AppTheme.lightTheme,
            initialRoute: Routes.splashRoute,
            onGenerateRoute: RouteGenerator.generateRoute,
          );

          // return MaterialApp(title: "Flutter App", home: ExampleScreen());
        },
      ),
    );
  }
}
