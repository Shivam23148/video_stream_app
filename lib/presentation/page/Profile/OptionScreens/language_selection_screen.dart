import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/core/Utils/language_enum.dart';
import 'package:ntavideofeedapp/core/controller/language_change_controller.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  Language? selectLanguage;
  Language? originalLanguage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final currentLocal = Provider.of<LanguageChangeController>(
      context,
      listen: false,
    ).appLocale;
    originalLanguage = currentLocal?.languageCode == 'hi'
        ? Language.hindi
        : Language.english;
    selectLanguage = originalLanguage;
  }

  bool get hasChanged => selectLanguage != originalLanguage;

  Future<bool> confirmLanguageChange() async {
    if (!hasChanged) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,

            title: Text("Confirm Language Change"),
            content: Text("Do you want to apply this language?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  final provider = Provider.of<LanguageChangeController>(
                    context,
                    listen: false,
                  );
                  if (selectLanguage != null) {
                    provider.changeLanguage(
                      selectLanguage == Language.english
                          ? Locale('en')
                          : Locale('hi'),
                    );
                  }
                  Navigator.of(context).pop(true);
                },
                child: Text("Confirm"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await confirmLanguageChange();
          if (shouldPop) Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Select Language'),
          actions: [
            TextButton(
              onPressed: hasChanged
                  ? () async {
                      final shouldPop = await confirmLanguageChange();
                      if (shouldPop) Navigator.of(context).pop();
                    }
                  : null,
              style: TextButton.styleFrom(
                foregroundColor: hasChanged ? Colors.blue : Colors.grey,
              ),
              child: Text("Save"),
            ),
          ],
        ),
        body: Column(
          children: [
            RadioListTile<Language>(
              title: Text("English"),
              value: Language.english,
              groupValue: selectLanguage,
              onChanged: (value) => setState(() {
                selectLanguage = value;
              }),
            ),
            RadioListTile<Language>(
              title: Text("Hindi"),
              value: Language.hindi,
              groupValue: selectLanguage,
              onChanged: (value) => setState(() {
                selectLanguage = value;
              }),
            ),
          ],
        ),
      ),
    );
  }
}
