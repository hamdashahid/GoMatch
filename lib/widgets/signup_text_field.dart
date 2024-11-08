import 'package:flutter/material.dart';

class SignupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final bool isPassword;

  const SignupTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 16.0, color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white, fontSize: 10.0),
      ),
      style: const TextStyle(fontSize: 16.0, color: Colors.white),
    );
  }
}
