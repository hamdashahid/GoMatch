import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/home_screen.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/utils/colors.dart';

class VerificationScreen extends StatefulWidget {
  static const String idScreen = "verification";
  bool? ispassenger;
  String? name;
  String? email;
  String? phone;
  String? password;

  VerificationScreen(
      {super.key,
      this.ispassenger,
      this.name,
      this.email,
      this.phone,
      this.password});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isEmailVerified = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      checkEmailVerified();
    } else {
      Navigator.pushReplacementNamed(context, 'loginScreen');
    }
  }

  Future<void> checkEmailVerified() async {
    await user?.reload(); // Reload to get the latest verification status
    user = _auth.currentUser;
    setState(() {
      isEmailVerified = user?.emailVerified ?? false;
      isLoading = false;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email has been verified.")),
      );
      // Attempt to create a new user account

      if (widget.ispassenger == true) {
        await FirebaseFirestore.instance
            .collection('passenger_profile')
            .doc(user!.uid)
            .set({
          'name': widget.name,
          'phone': widget.phone,
          'email': widget.email,
          'password': widget.password,
        });
      } else {
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(user!.uid)
            .set({
          'name': widget.name,
          'phone': widget.phone,
          'email': widget.email,
          'password': widget.password,
        });
      }

      Navigator.pushReplacementNamed(context, LoginScreen.idScreen);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please verify your email before proceeding.")),
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification email resent to ${user?.email}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to resend verification email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "A verification email has been sent to ${user?.email}. Please verify your email to continue.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // primary: AppColors.primaryColor,
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.primaryColor,
                    ),
                    onPressed: checkEmailVerified,
                    child: Text("Check Verification Status"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // primary: AppColors.primaryColor,
                      backgroundColor: AppColors.secondaryColor,
                      foregroundColor: AppColors.primaryColor,
                    ),
                    onPressed: resendVerificationEmail,
                    child: Text("Resend Verification Email"),
                  ),
                ],
              ),
            ),
    );
  }
}
