import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/providers/signup_service.dart';
import 'package:gomatch/widgets/signup_text_field.dart';
import 'package:gomatch/screens/login_screen.dart';

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
                    const SizedBox(height: 1.0),
                    SignupTextField(
                      controller: emailTextEditingController,
                      labelText: "Email",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 1.0),
                    SignupTextField(
                      controller: phoneTextEditingController,
                      labelText: "Phone",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 1.0),
                    SignupTextField(
                      controller: passwordTextEditingController,
                      labelText: "Password",
                      isPassword: true,
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
                      onPressed: () {
                        SignupService.registerNewUser(
                          context,
                          nameTextEditingController.text,
                          emailTextEditingController.text,
                          phoneTextEditingController.text,
                          passwordTextEditingController.text,
                        );
                      },
                      child: const Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context, LoginScreen.idScreen,
                          (route) => false, // Use the correct route name
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
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
