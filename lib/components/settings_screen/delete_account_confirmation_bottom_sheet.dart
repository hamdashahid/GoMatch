import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/utils/colors.dart';

class DeleteAccountConfirmationBottomSheet extends StatefulWidget {
  @override
  _DeleteAccountConfirmationBottomSheetState createState() =>
      _DeleteAccountConfirmationBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return DeleteAccountConfirmationBottomSheet();
      },
    );
  }
}

class _DeleteAccountConfirmationBottomSheetState
    extends State<DeleteAccountConfirmationBottomSheet> {
  Future<void> deleteAccount(BuildContext context) async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        final driverCollection =
            FirebaseFirestore.instance.collection('driver_profile');
        final passengerCollection =
            FirebaseFirestore.instance.collection('passenger_profile');

        // Fetch the user's profile from Firestore
        final driverSnapshot = await driverCollection.doc(userId).get();
        final passengerSnapshot = await passengerCollection.doc(userId).get();

        if (driverSnapshot.exists) {
          print('User is a driver, delete driver profile');
          // User is a driver, delete driver profile
          await driverCollection.doc(userId).delete();
          await currentUser.delete();
          // await FirebaseAuth.instance.currentUser?.delete();
        } else if (passengerSnapshot.exists) {
          // User is a passenger, delete passenger profile
          print('User is a passenger, delete passenger profile');
          await passengerCollection.doc(userId).delete();
          await currentUser.delete();
          // await FirebaseAuth.instance.currentUser?.delete();
        } else {
          // User profile not found
          print('User profile not found.');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User profile not found.')),
            );
          }
          return;
        }

        // Sign out the user
        await FirebaseAuth.instance.signOut();

        // Navigate to the login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account deleted successfully.')),
        );
        print('Account deleted successfully.');
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        if (context.mounted) {
          // Handle case where re-authentication is required
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please re-login to delete your account.')),
          );
        }
      } else {
        if (context.mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Delete Account',
              style: TextStyle(fontSize: 18, color: Colors.white)),
          const SizedBox(height: 20),
          const Text('Are you sure you want to delete your account?',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('Cancel',
                    style: TextStyle(color: AppColors.secondaryColor)),
              ),
              TextButton(
                onPressed: () {
                  // Handle account deletion
                  deleteAccount(context);
                  // Navigator.pop(context); // Close the bottom sheet
                },
                child: const Text('Delete Account',
                    style: TextStyle(color: AppColors.secondaryColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DeleteAccountConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Account'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Delete Account',
                style: TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 20),
            const Text('Are you sure you want to delete your account?',
                style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the screen
                  },
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.secondaryColor)),
                ),
                TextButton(
                  onPressed: () {
                    // Handle account deletion
                    deleteAccount(context);
                    Navigator.pop(context); // Close the screen
                  },
                  child: const Text('Delete Account',
                      style: TextStyle(color: AppColors.secondaryColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> deleteAccount(BuildContext context) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        String userId = currentUser.uid;

        final driverCollection =
            FirebaseFirestore.instance.collection('driver_profile');
        final passengerCollection =
            FirebaseFirestore.instance.collection('passenger_profile');

        final driverSnapshot = await driverCollection.doc(userId).get();
        final passengerSnapshot = await passengerCollection.doc(userId).get();

        if (driverSnapshot.exists) {
          await driverCollection.doc(userId).delete();
          await currentUser.delete();
        } else if (passengerSnapshot.exists) {
          await passengerCollection.doc(userId).delete();
          await currentUser.delete();
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User profile not found.')),
            );
          }
          return;
        }

        await FirebaseAuth.instance.signOut();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account deleted successfully.')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please re-login to delete your account.')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}
