import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/localization/language_change_controller.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/shared/widgets/selection_button.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/shared/utils/snackbar_util.dart';
import 'package:ntavideofeedapp/core/Utils/language_enum.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardScreen extends StatefulWidget {
  OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  bool isButtonPressed = false;
  Language? selectedLanguage;
  void onLanguageSelected(Language lang) {
    setState(() {
      selectedLanguage = lang;
    });
  }

  Future<void> _onSavePressed() async {
    if (selectedLanguage == null) {
      SnackbarUtil.showSnackbar(
        message: "Please Select a Language",
        backgroundColor: Colors.red,
      );

      return;
    }
    final provider = Provider.of<LanguageChangeController>(
      context,
      listen: false,
    );
    final locale = selectedLanguage == Language.english
        ? Locale('en')
        : Locale('hi');
    provider.changeLanguage(locale);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      'language_code',
      selectedLanguage == Language.english ? 'en' : 'hi',
    );
    await sp.setBool('is_language_selected', true);
    Navigator.pushNamedAndRemoveUntil(context, Routes.homeRoute, (_) => false);
  }

  void buttonPressed() {
    setState(() {
      if (isButtonPressed == false) {
        isButtonPressed = true;
      } else if (isButtonPressed == true) {
        isButtonPressed = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSavePressed,
        label: Text("Get Started"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: Icon(Icons.arrow_forward),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SelectionButton(
            isButtonPressed: selectedLanguage == Language.english,
            label: 'English',
            onTap: () => onLanguageSelected(Language.english),
          ),
          SelectionButton(
            isButtonPressed: selectedLanguage == Language.hindi,
            label: 'हिन्दी',
            onTap: () => onLanguageSelected(Language.hindi),
          ),
        ],
      ),
    );
  }
}
