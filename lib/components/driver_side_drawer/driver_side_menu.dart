import 'package:flutter/material.dart';
import 'package:gomatch/components/driver_side_drawer/driver_menu_item_list.dart';
import 'package:gomatch/components/driver_side_drawer/driver_side_menu_tile.dart';
import 'package:gomatch/screens/driver_dashboard.dart';
import 'package:gomatch/screens/driver_history_screen.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/screens/driver_profile_screen.dart';
import 'package:gomatch/screens/driver_settings_screen.dart';
// import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/screens/faq_screen.dart';
// import 'package:gomatch/screens/history_screen.dart';
// import 'package:gomatch/screens/home_screen.dart';
// import 'package:gomatch/screens/driver_profile_screen.dart';
import 'package:gomatch/screens/settings_screen.dart';
import 'package:gomatch/utils/colors.dart';

class DriverSideMenu extends StatefulWidget {
  final bool isMenuOpen;

  const DriverSideMenu({super.key, required this.isMenuOpen});

  @override
  State<DriverSideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<DriverSideMenu> {
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
                              Navigator.pushNamed(context, DriverModeScreen.idScreen);
                              break;
                            case "Profile":
                              Navigator.pushNamed(
                                  context, DriverProfileScreen.idScreen);
                              break;
                            case "Ride Requests":
                              // Navigator.pushNamed(
                              //     context, DriverHistoryScreen.idScreen);
                              break;
                            case "Dashboard":
                              Navigator.pushNamed(
                                  context, DriverDashboardScreen.idScreen);
                              break;
                            case "Settings":
                              Navigator.pushNamed(
                                  context, DriverSettingsScreen.idScreen);
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
