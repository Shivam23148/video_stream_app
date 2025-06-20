import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Home/home_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Keycloak%20Redirect/keycloak_authentication_redirect.dart';
import 'package:ntavideofeedapp/routes/route_names.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const KeycloakAuthenticationRedirectScreen(),
        );
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const ExampleScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
