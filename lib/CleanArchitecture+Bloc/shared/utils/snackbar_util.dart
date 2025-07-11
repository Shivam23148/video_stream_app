import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackbarUtil {
  static final GlobalKey<ScaffoldMessengerState> messangerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.white,
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      backgroundColor: backgroundColor,
      action: action,
    );
    messangerKey.currentState?.hideCurrentSnackBar();
    messangerKey.currentState?.showSnackBar(snackBar);
  }
}
