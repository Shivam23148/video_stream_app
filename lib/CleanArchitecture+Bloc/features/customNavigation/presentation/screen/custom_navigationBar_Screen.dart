import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/navItem_model.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/nav_items_config.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/presentation/cubit/navbar_cubit.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/shared/utils/snackbar_util.dart';
import 'package:provider/provider.dart';

class CustomNavigationbarScreen extends StatefulWidget {
  const CustomNavigationbarScreen({super.key});

  @override
  State<CustomNavigationbarScreen> createState() =>
      _CustomNavigationbarScreenState();
}

class _CustomNavigationbarScreenState extends State<CustomNavigationbarScreen> {
  late List<NavItem> selectedItems = [];
  final int minSelectionCount = 4;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<NavbarCubit>().state;
      if (state is NavbarLoaded) {
        setState(() {
          selectedItems = List.from(state.navItems);
        });
      }
    });
  }

  void toggleItem(NavItem item) {
    setState(() {
      if (isSelect(item)) {
        if (selectedItems.length <= minSelectionCount) {
          SnackbarUtil.showSnackbar(
            message: "You must select at least $minSelectionCount icons",
            backgroundColor: Colors.red,
          );
          return;
        }

        selectedItems.removeWhere((e) => e.id == item.id);
      } else {
        selectedItems.add(item);
      }
    });
  }

  bool isSelect(NavItem item) => selectedItems.any((e) => e.id == item.id);
  void saveSelection() {
    context.read<NavbarCubit>().updateSelection(selectedItems);
    Navigator.pop(context);
  }

  void resetToDefault() {
    context.read<NavbarCubit>().updateSelection(defaultNavItems);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavbarCubit, NavbarState>(
      builder: (context, state) {
        if (state is NavbarLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is NavbarLoaded) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text("Customize Navigation Bar"),
              actions: [
                TextButton(
                  onPressed: resetToDefault,
                  child: Text("Reset", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            body: ListView.builder(
              itemCount: allNavItems.length,
              itemBuilder: (context, index) {
                final item = allNavItems[index];
                return CheckboxListTile(
                  title: Text(item.title),
                  value: isSelect(item),
                  secondary: Icon(item.icon),
                  onChanged: item.id == 'profile'
                      ? null
                      : (_) => toggleItem(item),
                );
              },
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: selectedItems.length >= minSelectionCount
                    ? saveSelection
                    : null,
                child: const Text("Save"),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }
      },
    );
  }
}
