import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class PrivacyPolicyBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Privacy Policy', style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Your privacy is important to us.', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              TextButton(
                child: const Text('Close', style: TextStyle(color: AppColors.secondaryColor)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
