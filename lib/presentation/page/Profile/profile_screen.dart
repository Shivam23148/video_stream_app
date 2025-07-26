import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/core/router/route_names.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/Playback/presentation/screen/playback_screen.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/customNavigation/presentation/screen/custom_navigationBar_Screen.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/rocketchat/presentation/rocket_chat_webview.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';

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
    'Rocket Chat',
    'NTFY',
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
      case 'Rocket Chat':
        _navigateToRocketChat();
        break;
      case 'NTFY':
        _navigateToNtfy();
      default:
        logger.d("No action defined for $option");
    }
  }

  void _navigateToNtfy() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExampleScreen()));
  }

  void _navigateToRocketChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RocketChatWebview()),
    );
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
    logger.i("Navigate to profile pressed");
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
