import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/theme/color_palette.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColor.primaryColor,
    scaffoldBackgroundColor: AppColor.backgroundColor,
    appBarTheme: AppBarTheme(backgroundColor: AppColor.backgroundColor),
  );
}
