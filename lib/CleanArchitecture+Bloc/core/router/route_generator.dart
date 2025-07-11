import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/onboard/presentation/screen/onboard_screen.dart';
import 'package:ntavideofeedapp/presentation/page/DeviceList/device_list_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Home/home_screen.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/auth/presentation/screens/auth_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Keycloak%20Redirect/keycloak_authentication_redirect.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/main/presentation/screens/main_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Profile/OptionScreens/language_selection_screen.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/splash/presentation/screens/splash_screen.dart';
import 'package:ntavideofeedapp/presentation/page/VideoPlayer/test_screen.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/router/route_names.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => AuthScreen());
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => MainScreen());
      case Routes.languageSelectionRoute:
        return MaterialPageRoute(builder: (_) => LanguageSelectionScreen());
      case Routes.deviceListRoute:
        return MaterialPageRoute<String?>(builder: (_) => DeviceListScreen());

      case Routes.onboardingRoute:
        return MaterialPageRoute(builder: (_) => OnboardScreen());
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
