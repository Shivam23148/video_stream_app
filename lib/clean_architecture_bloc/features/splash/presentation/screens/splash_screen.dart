import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_names.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<SplashBloc>()..add(CheckAuthStatusSplash()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocListener<SplashBloc, SplashState>(
          listener: (context, state) {
            if (state is SplashAuthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.homeRoute,
                (_) => false,
              );
            } else if (state is SplashUnauthenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginRoute,
                (_) => false,
              );
            }
          },
          child: Center(child: Text("Splash Screen.....")),
        ),
      ),
    );
  }
}
