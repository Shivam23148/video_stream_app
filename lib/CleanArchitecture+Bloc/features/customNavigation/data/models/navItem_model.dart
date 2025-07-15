import 'package:flutter/material.dart';
import 'package:ntavideofeedapp/main.dart';

class NavItem {
  final String id;
  final String title;
  final IconData icon;
  final Widget screen;

  NavItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.screen,
  });

  static List<String> toIDList(List<NavItem> items) =>
      items.map((e) => e.id).toList();
  static List<NavItem> fromIdList(List<String> ids, List<NavItem> allItems) {
    List<NavItem> result = [];
    for (var id in ids) {
      try {
        result.add(allItems.firstWhere((item) => item.id == id));
      } catch (e) {
        logger.e("Nav item with $id not found in allNavitems");
      }
    }
    return result;
  }
}
