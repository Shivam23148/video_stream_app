import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/chat/presentation/screen/chat_screen.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/customNavigation/data/models/navItem_model.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/main/presentation/screens/main_screen.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/onboard/presentation/screen/onboard_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/LiveView/live_view_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Profile/profile_screen.dart';

final List<NavItem> allNavItems = [
  NavItem(
    id: 'home',
    title: 'Home',
    icon: Icons.home,
    screen: ExampleScreen() /* OnboardScreen() */,
  ),
  NavItem(
    id: 'liveView',
    title: 'Live View',
    icon: Icons.videocam,
    screen: LiveViewScreen(),
  ),
  NavItem(
    id: 'profile',
    title: 'Profile',
    icon: Icons.person,
    screen: ProfileScreen(),
  ),
  NavItem(
    id: 'settings',
    title: 'Settings',
    icon: Icons.settings,
    screen: Center(child: Text("Settings")),
  ),
  NavItem(
    id: 'help',
    title: 'Help & Support',
    icon: Icons.help,
    screen: Center(child: Text("Help & Support")),
  ),

  NavItem(id: 'other', title: 'Chat', icon: Icons.chat, screen: ChatScreen()),
];
final List<NavItem> defaultNavItems = [
  NavItem(
    id: 'home',
    title: 'Home',
    icon: Icons.home,
    screen: ExampleScreen() /*  OnboardScreen() */,
  ),
  NavItem(
    id: 'liveView',
    title: 'Live View',
    icon: Icons.videocam,
    screen: LiveViewScreen(),
  ),
  NavItem(id: 'other', title: 'Chat', icon: Icons.chat, screen: ChatScreen()),
  NavItem(
    id: 'profile',
    title: 'Profile',
    icon: Icons.person,
    screen: ProfileScreen(),
  ),
];
