import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/config/service_locator.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/navItem_model.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/nav_items_config.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/main/presentation/cubit/navigator_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/shared/utils/snackbar_util.dart';
import 'package:ntavideofeedapp/presentation/page/Example/example_screen.dart';
import 'package:ntavideofeedapp/presentation/page/LiveView/live_view_screen.dart';
import 'package:ntavideofeedapp/presentation/page/Profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<NavigatorCubit>()),
        BlocProvider(create: (_) => serviceLocator<NavbarCubit>()),
      ],
      child: _MainScreenView(),
    );
  }
}

class _MainScreenView extends StatelessWidget {
  const _MainScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavbarCubit, NavbarState>(
      builder: (context, state) {
        if (state is NavbarLoading) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.blue)),
          );
        } else if (state is NavbarLoaded) {
          return BlocBuilder<NavigatorCubit, int>(
            builder: (context, selectedIndex) {
              final navItems = state.navItems;
              return Scaffold(
                /* floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    context.read<NavbarCubit>().updateSelection(
                      defaultNavItems,
                    );
                    /*  final sp = await SharedPreferences.getInstance();
                    await sp.setBool("is_language_selected", false);
                    print(
                      "Value of language selected is : ${sp.getBool("is_language_selected")}",
                    );
                    SnackbarUtil.showSnackbar(
                      message: "Language Value Reset Successful",
                      backgroundColor: Colors.green,
                    ); */
                  },
                  child: Icon(Icons.language),
                ), */
                body: IndexedStack(
                  index: selectedIndex,
                  children: navItems.map((item) => item.screen).toList(),
                ),
                bottomNavigationBar: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      currentIndex: selectedIndex,
                      onTap: (index) =>
                          context.read<NavigatorCubit>().selectTab(index),
                      type: BottomNavigationBarType.fixed,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.grey[600],
                      selectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                      items: navItems.map((item) {
                        return BottomNavigationBarItem(
                          icon: Icon(item.icon),
                          label: item.title,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        }
        return Scaffold(body: Center(child: Text("Something went wrong")));
      },
    );
  }
}

class OtherScreen2 extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Other screen 2")));
  }
}
