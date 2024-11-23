import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/screens/signup_screen.dart';
import 'package:gomatch/providers/login_service.dart'; // Import the login service
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:gomatch/screens/home_screen.dart'; // Import HomeScreen

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  static const String idScreen = "LogIn";
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
          Navigator.pushReplacementNamed(context, HomeScreen.idScreen);
        } else if (driverDoc.exists) {
          // Navigate to driver dashboard
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
}
