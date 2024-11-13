import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/home_screen.dart';

class VerificationScreen extends StatefulWidget {
  static const String idScreen = "verification";

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
      Navigator.pushReplacementNamed(context, HomeScreen.idScreen);
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
        title: Text("Email Verification"),
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
                    onPressed: checkEmailVerified,
                    child: Text("Check Verification Status"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: resendVerificationEmail,
                    child: Text("Resend Verification Email"),
                  ),
                ],
              ),
            ),
    );
  }
}
