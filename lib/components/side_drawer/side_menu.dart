import 'package:flutter/material.dart';
import 'package:gomatch/components/side_drawer/menu_item_list.dart';
import 'package:gomatch/components/side_drawer/side_menu_tile.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/screens/faq_screen.dart';
import 'package:gomatch/screens/history_screen.dart';
import 'package:gomatch/screens/home_screen.dart';
import 'package:gomatch/screens/profile_screen.dart';
import 'package:gomatch/screens/settings_screen.dart';
import 'package:gomatch/utils/colors.dart';

class SideMenu extends StatefulWidget {
  final bool isMenuOpen;

  const SideMenu({super.key, required this.isMenuOpen});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  int selectedIndex = 0; // Track the selected menu index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 288,
        height: double.infinity,
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Add "GoMatch" title
              const Text(
                "GoMatch",
                style: TextStyle(
                  fontSize: 24, // Change font size as needed
                  fontWeight: FontWeight.bold, // Make it bold
                  color: AppColors.secondaryColor, // Change text color if needed
                ),
              ),
              const SizedBox(height: 20), // Space between title and menu items
              // Display side menu items
              Expanded(
                child: ListView.builder(
                  itemCount: sideMenus.length, // Use the length of sideMenus
                  itemBuilder: (context, index) {
                    final menu = sideMenus[index];
                    return SideMenuTile(
                      menu: menu,
                      isActive: selectedIndex == index,
                      press: () {
                        setState(() {
                          selectedIndex = index; // Update selected index
                        });
                        // Introduce a delay before navigating
                        Future.delayed(const Duration(milliseconds: 200), () {
                          // Navigate to the relevant screen
                          switch (menu.title) {
                            case "Home":
                              Navigator.pushNamed(context, HomeScreen.idScreen);
                              break;
                            case "Profile":
                              Navigator.pushNamed(
                                  context, ProfileScreen.idScreen);
                              break;
                            case "Request History":
                              Navigator.pushNamed(
                                  context, HistoryScreen.idScreen);
                              break;
                            case "Driver Mode":
                              Navigator.pushNamed(
                                  context, DriverModeScreen.idScreen);
                              break;
                            case "Settings":
                              Navigator.pushNamed(
                                  context, SettingsScreen.idScreen);
                              break;
                            case "FAQ":
                              Navigator.pushNamed(context, FAQScreen.idScreen);
                              break;

                            default:
                              break;
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
