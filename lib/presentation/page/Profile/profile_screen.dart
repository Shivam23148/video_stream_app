import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/Playback/presentation/screen/playback_screen.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/presentation/screen/custom_navigationBar_Screen.dart';

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
    'Customize Navigation Bar',
    'Terms & Privacy',
    'Help & Support',
    'Security',
    'Playback',
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
      case 'Customize Navigation Bar':
        _navigateToCustomizeNavBar();
        break;
      case 'Playback':
        _navigateToPlayback();
        break;
      default:
        print("No action defined for ${option}");
    }
  }

  void _navigateToCustomizeNavBar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: serviceLocator<NavbarCubit>(),
          child: CustomNavigationbarScreen(),
        ),
      ),
    );
  }

  void _navigateToProgile() {
    print("Navigate to profile pressed");
  }

  void _navigateToPlayback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PlaybackScreen()),
    );
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
