import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gomatch/screens/home_screen.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/utils/firebase_ref.dart'; // Assuming you have defined usersRef here

class SignupService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static Future<void> registerNewUser(
    BuildContext context,
    String name,
    String email,
    String phone,
    String password,
  ) async {
    if (name.length < 3) {
      _displayToastMessage("Name must be at least 3 characters.", context);
    } else if (!email.contains("@")) {
      _displayToastMessage("Email address is not valid.", context);
    } else if (phone.isEmpty) {
      _displayToastMessage("Phone number is mandatory.", context);
    } else if (password.length < 6) {
      _displayToastMessage("Password must be at least 6 characters.", context);
    } else {
      try {
        UserCredential userCredential = await _firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);

        User? firebaseUser = userCredential.user;
        if (firebaseUser != null) {
          Map<String, String> userDataMap = {
            "name": name.trim(),
            "email": email.trim(),
            "phone": phone.trim(),
          };
          usersRef.child(firebaseUser.uid).set(userDataMap);

          _displayToastMessage("Congratulations, your account has been created.", context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        } else {
          _displayToastMessage("New user account has not been created.", context);
        }
      } catch (e) {
        _displayToastMessage("Error: $e", context);
      }
    }
  }

  static void _displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }
}
