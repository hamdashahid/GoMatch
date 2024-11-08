import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth import
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/screens/login_screen.dart'; // Your login screen import

class LogoutConfirmationBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Logout Confirmation', style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut(); // Firebase sign out
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );

                        // Show SnackBar message after logging out
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('You have been logged out successfully.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      } catch (e) {
                        // Handle any errors if logout fails
                        print("Logout failed: $e");
                      }
                    },
                    child: const Text('Logout', style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
