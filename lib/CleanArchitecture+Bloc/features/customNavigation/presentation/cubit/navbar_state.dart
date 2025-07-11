part of 'navbar_cubit.dart';

abstract class NavbarState {}

class NavbarLoading extends NavbarState {}

class NavbarLoaded extends NavbarState {
  final List<NavItem> navItems;

  NavbarLoaded(this.navItems);
}
