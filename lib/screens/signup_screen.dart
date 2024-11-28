import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/widgets/signup_text_field.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/screens/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? error;

  // Register a new user and send verification email if all inputs are valid
  static Future<void> registerNewUser(
    BuildContext context,
    String name,
    String email,
    String phone,
    String password,
    bool ispassenger,
  ) async {
    error = null; // Reset error at the start of registration

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      error = "All fields must be filled in.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
      return;
    }

    if (password.length < 6) {
      error = "Password must be at least 6 characters.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
      return;
    }

    try {
      // Attempt to create a new user account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Save additional user data in Firestore
        await user.sendEmailVerification();
        // Send email verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Verification email sent to $email. Please verify your email."),
          ),
        );

        // Redirect user to the verification screen after registration
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
                ispassenger: ispassenger,
                name: name,
                email: email,
                phone: phone,
                password: password),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        error = "An account already exists with this email. Please login.";
      } else if (e.code == 'invalid-email') {
        error = "The email address is not valid.";
      } else if (e.code == 'weak-password') {
        error = "The password is too weak.";
      } else {
        error = "Registration error: $e";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
    } catch (e) {
      error = "An unexpected error occurred: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
    }
  }
}

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});
  static const String idScreen = "SignUp";

  final TextEditingController nameTextEditingController =
      TextEditingController();
  final TextEditingController emailTextEditingController =
      TextEditingController();
  final TextEditingController phoneTextEditingController =
      TextEditingController();
  final TextEditingController passwordTextEditingController =
      TextEditingController();

  void _showAccountTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
            "Select Account Type",
            style: TextStyle(color: AppColors.secondaryColor),
          ),
          content: const Text(
            "Please choose an account type to create.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Navigator.of(context).pop();
                await SignupService.registerNewUser(
                  context,
                  nameTextEditingController.text,
                  emailTextEditingController.text,
                  phoneTextEditingController.text,
                  passwordTextEditingController.text,
                  true, // isPassenger = true
                );
              },
              child: const Text(
                "Passenger",
                style: TextStyle(color: AppColors.secondaryColor),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Navigator.of(context).pop();
                await SignupService.registerNewUser(
                  context,
                  nameTextEditingController.text,
                  emailTextEditingController.text,
                  phoneTextEditingController.text,
                  passwordTextEditingController.text,
                  false, // isPassenger = false
                );
              },
              child: const Text(
                "Driver",
                style: TextStyle(color: AppColors.secondaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 40.0),
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
                    SignupTextField(
                      controller: nameTextEditingController,
                      labelText: "Name",
                    ),
                    SignupTextField(
                      controller: emailTextEditingController,
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SignupTextField(
                      controller: phoneTextEditingController,
                      labelText: "Phone",
                      keyboardType: TextInputType.phone,
                    ),
                    SignupTextField(
                      controller: passwordTextEditingController,
                      labelText: "Password",
                      isPassword: true,
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                          foregroundColor: AppColors.primaryColor),
                      onPressed: () async {
                        // await SignupService.registerNewUser(
                        //   context,
                        //   nameTextEditingController.text,
                        //   emailTextEditingController.text,
                        //   phoneTextEditingController.text,
                        //   passwordTextEditingController.text,
                        //   true,
                        // );
                        _showAccountTypeDialog(context);
                      },
                      // style: ElevatedButton.styleFrom(
                      //   primary: AppColors.secondaryColor,
                      // ),
                      child: const Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // ElevatedButton(
                    //   onPressed: () async {
                    //     await SignupService.registerNewUser(
                    //       context,
                    //       nameTextEditingController.text,
                    //       emailTextEditingController.text,
                    //       phoneTextEditingController.text,
                    //       passwordTextEditingController.text,
                    //       false,
                    //     );
                    //   },
                    //   child: const Center(
                    //     child: Text(
                    //       "Create Driver Account",
                    //       style: TextStyle(
                    //           fontSize: 18.0, fontFamily: "Brand Bold"),
                    //     ),
                    //   ),
                    // ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          LoginScreen.idScreen,
                          (route) => false,
                        );
                      },
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                      child: const Text("Already have an Account? Login Here."),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
