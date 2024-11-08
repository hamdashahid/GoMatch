// side_menu_data.dart (or in side_menu.dart)
import 'package:flutter/material.dart';
import 'menu_item.dart';

final List<MenuItem> sideMenus = [
  MenuItem(title: "Home", icon: Icons.home),
  MenuItem(title: "Profile", icon: Icons.person_2_outlined),
  MenuItem(title: "Request History", icon: Icons.history),
  MenuItem(title: "Driver Mode", icon: Icons.drive_eta),
  MenuItem(title: "Settings", icon: Icons.settings),
  MenuItem(title: "FAQ", icon: Icons.question_answer),
];
