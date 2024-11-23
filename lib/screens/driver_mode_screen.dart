import 'package:flutter/material.dart';
import 'package:gomatch/components/driver_side_drawer/driver_side_menu.dart';
import 'package:gomatch/models/driver_menu_btn.dart';
import 'package:gomatch/utils/colors.dart';

class DriverModeScreen extends StatefulWidget {
  static const String idScreen = "DriverModeScreen";

  const DriverModeScreen({super.key});

  @override
  _DriverModeScreenState createState() => _DriverModeScreenState();
}

class _DriverModeScreenState extends State<DriverModeScreen> {
  bool isSideMenuClosed = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AnimatedPositioned(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        left: isSideMenuClosed ? -288 : 0,
        height: MediaQuery.of(context).size.height,
        child: DriverSideMenu(isMenuOpen: !isSideMenuClosed),
      ),
      appBar: AppBar(
        title: const Text('Driver Mode'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/145.png',
              fit: BoxFit.fitHeight,
            ),
          ),

          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 270),
                      const Text(
                        'Welcome, Driver!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Join us at GoMatch and help us connect passengers with safe and reliable rides!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // const SizedBox(height: 20),
                      // Image.asset(
                      //   'assets/images/taxi.png',
                      //   height: 200,
                      //   fit: BoxFit.cover,
                      // ),
                    ],
                  ),
                ),

                // Features Section
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Why Join GoMatch?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _featureTile(
                        icon: Icons.access_time_rounded,
                        title: 'Flexible Hours',
                        description:
                            'Drive whenever you want and earn on your own schedule.',
                      ),
                      const SizedBox(height: 15),
                      _featureTile(
                        icon: Icons.money_rounded,
                        title: 'Competitive Earnings',
                        description:
                            'Keep more of what you earn with our transparent payout system.',
                      ),
                      const SizedBox(height: 15),
                      _featureTile(
                        icon: Icons.security_rounded,
                        title: 'Safety First',
                        description:
                            'We prioritize safety for both drivers and passengers.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 40),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
