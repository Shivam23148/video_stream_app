import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/navItem_model.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/features/customNavigation/data/models/nav_items_config.dart';
import 'package:ntavideofeedapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'navbar_state.dart';

class NavbarCubit extends Cubit<NavbarState> {
  static const _prefsKey = 'selected_nav_items';
  NavbarCubit() : super(NavbarLoading()) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList(_prefsKey);
    final selected = NavItem.fromIdList(
      savedIds ?? NavItem.toIDList(defaultNavItems), // use default if null
      allNavItems, // all items reference list
    );
    logger.d(
      "Selected list is: ${selected.map((i) => "id: ${i.id}: title: ${i.title}").join('\n')}",
    );

    emit(NavbarLoaded(selected));
  }

  Future<void> updateSelection(List<NavItem> selected) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, NavItem.toIDList(selected));
    emit(NavbarLoaded(List<NavItem>.from(selected)));
  }
}
