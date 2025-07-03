import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/LiveView/live_view_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectIndex = 0;
  final List<Widget> _pages = [
    ExampleScreen(),
    LiveViewScreen(),
    OtherScreen2(),
    ProfileScreen(),
  ];

  void onSelectedPage(int index) {
    if (selectIndex != index) {
      setState(() {
        selectIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectIndex,
        onTap: onSelectedPage,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.ac_unit_sharp),
            label: 'Other Screen1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.accessibility_new),
            label: 'Other Screen2',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class OtherScreen2 extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Other screen 2")));
  }
}
