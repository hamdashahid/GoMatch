import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/screens/home_screen.dart';

Future<void> loginUser(BuildContext context, String email, String password) async {
  try {
    // Attempt to sign in the user
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // If login is successful, navigate to the HomeScreen
    if (userCredential.user != null) {
      displayToastMessage('Welcome back, ${userCredential.user!.email}!', context); // Show success message
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.idScreen, (route) => false);
    }
  } on FirebaseAuthException catch (e) {
    String errorMessage;
    // Handle different types of errors
    if (e.code == 'user-not-found') {
      errorMessage = "No user found for that email.";
    } else if (e.code == 'wrong-password') {
      errorMessage = "Wrong password provided.";
    } else {
      errorMessage = "Login failed. Please try again.";
    }
    // Display the error message
    displayToastMessage(errorMessage, context);
  } catch (e) {
    // Handle any other exceptions
    displayToastMessage("An unexpected error occurred.", context);
  }
}

// Function to display a toast message
void displayToastMessage(String message, BuildContext context) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final snackBar = SnackBar(
    content: Text(message),
    duration: const Duration(seconds: 3),
  );
  scaffoldMessenger.showSnackBar(snackBar);
}
