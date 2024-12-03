// side_menu_data.dart (or in side_menu.dart)
import 'package:flutter/material.dart';
import 'driver_menu_item.dart';

final List<MenuItem> sideMenus = [
  MenuItem(title: "Home", icon: Icons.home),
  MenuItem(title: "Profile", icon: Icons.person_2_outlined),
  MenuItem(title: "Dashboard", icon: Icons.dashboard),
  MenuItem(title: "Ride Requests", icon: Icons.directions_car),
  MenuItem(title: "Payments", icon: Icons.payment),
  MenuItem(title: "Settings", icon: Icons.settings),
  MenuItem(title: "FAQ", icon: Icons.question_answer),
];
