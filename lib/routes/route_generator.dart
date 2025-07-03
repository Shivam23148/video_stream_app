import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/presentation/page/DeviceList/device_list_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Home/home_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Keycloak%20Redirect/auth_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Keycloak%20Redirect/keycloak_authentication_redirect.dart';
import 'package:ntavideofeedapp/presentation/page/Main/main_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Profile/OptionScreens/language_selection_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Splash/splash_screen.dart';
import 'package:ntavideofeedapp/presentation/page/VideoPlayer/test_screen.dart';
import 'package:ntavideofeedapp/routes/route_names.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case Routes.languageSelectionRoute:
        return MaterialPageRoute(builder: (_) => LanguageSelectionScreen());
      case Routes.deviceListRoute:
        return MaterialPageRoute<String>(builder: (_) => DeviceListScreen());
      //Test
      case Routes.testVideoPlayerRoute:
        final url = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => TestScreen(url: url));
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
