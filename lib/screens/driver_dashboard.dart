import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DashboardScreen extends StatelessWidget {
  static const String idScreen = "DashboardScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 215.0,
                  decoration: const BoxDecoration(
                    color: AppColors.lightPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 15.0),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const Center(
                              child: Text(
                                "Driver Dashboard",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Brand-Bold",
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Name : John Doe",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Brand-Bold",
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.red),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Phone : 1234567890",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Brand-Bold",
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Available Routes",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: const Text('Route 1'),
                        subtitle: const Text('From A to B'),
                        onTap: () {
                          // Implement route selection functionality here
                        },
                      ),
                      ListTile(
                        title: const Text('Route 2'),
                        subtitle: const Text('From C to D'),
                        onTap: () {
                          // Implement route selection functionality here
                        },
                      ),
                      ListTile(
                        title: const Text('Route 3'),
                        subtitle: const Text('From E to F'),
                        onTap: () {
                          // Implement route selection functionality here
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Pickup Locations",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const ListTile(
                        title: Text('Location 1'),
                        subtitle: Text('123 Main St'),
                      ),
                      const ListTile(
                        title: Text('Location 2'),
                        subtitle: Text('456 Elm St'),
                      ),
                      const ListTile(
                        title: Text('Location 3'),
                        subtitle: Text('789 Oak St'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () {
                    // Implement navigation or functionality
                  },
                  child: const Text(
                    "DONE",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Brand-Bold",
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
