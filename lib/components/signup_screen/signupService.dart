import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static String? error ; // Make `error` static to access it directly
  
    // Register a new user and send verification email if all inputs are valid
  static Future<void> registerNewUser(
    BuildContext context,
    String name,
    String email,
    String phone,
    String password,
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Save additional user data in Firestore
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'phone': phone,
          'email': email,
        });

        // Send email verification
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Verification email sent to $email. Please verify your email."),
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
