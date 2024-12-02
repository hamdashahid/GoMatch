import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/screens/signup_screen.dart';
import 'package:gomatch/providers/login_service.dart'; // Import the login service
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:gomatch/screens/home_screen.dart'; // Import HomeScreen

class LoginScreen extends StatefulWidget {
  static const String idScreen = "LogIn";

  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 65.0),
              const Image(
                image: AssetImage("assets/images/logoTransparent.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        foregroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 18.0, fontFamily: "Brand Bold"),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (!emailTextEditingController.text.contains("@")) {
                          displayToastMessage(
                              "Email address is not valid.", context);
                        } else if (passwordTextEditingController.text.isEmpty) {
                          displayToastMessage(
                              "Password is mandatory.", context);
                        } else if (passwordTextEditingController.text.length <
                            6) {
                          displayToastMessage(
                              "Password must be at least 6 characters.",
                              context);
                        } else {
                          loginAndAuthenticateUser(context);
                        }
                      },
                    ),
                    const SizedBox(height: 15.0),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          showForgotPasswordDialog(context);
                        },
                        child: Text("Forgot Password?",
                            style: TextStyle(color: AppColors.secondaryColor)),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignupScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text("Do not have an Account? Register Here."),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginAndAuthenticateUser(BuildContext context) async {
    String email = emailTextEditingController.text.trim();
    String password = passwordTextEditingController.text.trim();

    try {
      // Sign in the user
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Fetch user documents concurrently
        final passengerProfileFuture = FirebaseFirestore.instance
            .collection('passenger_profile')
            .doc(user.uid)
            .get();
        final driverProfileFuture = FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(user.uid)
            .get();

        // Wait for both futures to complete
        final List<DocumentSnapshot> results = await Future.wait([
          passengerProfileFuture,
          driverProfileFuture,
        ]);

        final passengerDoc = results[0];
        final driverDoc = results[1];

        if (passengerDoc.exists) {
          // Navigate to passenger dashboard
          await FirebaseFirestore.instance
              .collection('passenger_profile')
              .doc(user.uid)
              .update({'password': password});
          Navigator.pushReplacementNamed(context, HomeScreen.idScreen);
        } else if (driverDoc.exists) {
          // Navigate to driver dashboard
          await FirebaseFirestore.instance
              .collection('driver_profile')
              .doc(user.uid)
              .update({'password': password});
          Navigator.pushReplacementNamed(context, DriverModeScreen.idScreen);
        } else {
          // Neither profile exists
          displayToastMessage(
            "Login failed: Account is not registered!!",
            context,
          );
          FirebaseAuth.instance.signOut(); // Ensure user is signed out
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      } else {
        errorMessage = "Login failed. Please try again.";
      }
      displayToastMessage(errorMessage, context);
    } catch (e) {
      displayToastMessage(
          "An error occurred. Please try again later.", context);
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          title: Text("Forgot Password",
              style: TextStyle(color: AppColors.secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  border: OutlineInputBorder(),
                  // bo
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel",
                  style: TextStyle(color: AppColors.secondaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                foregroundColor: AppColors.primaryColor,
              ),
              onPressed: () async {
                await sendResetEmail(emailController.text, context);
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendResetEmail(String email, BuildContext context) async {
    try {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter your email")),
        );
        return;
      }
      try {
        // Fetch user documents concurrently
        final passengerProfileFuture = FirebaseFirestore.instance
            .collection('passenger_profile')
            .where('email', isEqualTo: email)
            .get();
        final driverProfileFuture = FirebaseFirestore.instance
            .collection('driver_profile')
            .where('email', isEqualTo: email)
            .get();

        // Wait for both futures to complete
        final List<QuerySnapshot> results = await Future.wait([
          passengerProfileFuture,
          driverProfileFuture,
        ]);

        final passengerDocs = results[0].docs;
        final driverDocs = results[1].docs;

        if (passengerDocs.isNotEmpty || driverDocs.isNotEmpty) {
          // Send password reset email
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

          if (!mounted) return;
          Navigator.of(context)
              .pop(); // Close the dialog after successful email send
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password reset email sent to $email")),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No user found with this email.")),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = "No user found with this email.";
        } else {
          errorMessage = "Failed to send reset email. Please try again.";
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred. Please try again later.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }
}
