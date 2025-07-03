import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/core/routes/route_names.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> optionsList = [
    'Profile',
    'Consent & Permission',
    'Settings',
    'Language',
    'Terms & Privacy',
    'Help & Support',
    'Security',
    'Logout',
  ];

  void handleOptionTap(String option) {
    switch (option) {
      case 'Profile':
        _navigateToProgile();
        break;
      case 'Language':
        _navigateToLanguage();
        break;
      default:
        print("No action defined for ${option}");
    }
  }

  void _navigateToProgile() {
    print("Navigate to profile pressed");
  }

  void _navigateToLanguage() {
    Navigator.pushNamed(context, Routes.languageSelectionRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: optionsList.length,
        itemBuilder: (context, index) {
          final item = optionsList[index];
          return Card(
            color: Colors.white,
            elevation: 2,
            child: ListTile(
              title: Text(item),
              onTap: () => handleOptionTap(item),
            ),
          );
        },
      ),
    );
  }
}
