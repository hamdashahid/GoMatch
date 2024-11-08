import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DeleteAccountConfirmationBottomSheet {
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
              Text('Delete Account', style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 20),
              const Text('Are you sure you want to delete your account?', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text('Cancel', style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                  TextButton(
                    onPressed: () {
                      // Handle account deletion
                      Navigator.pop(context); // Close the bottom sheet
                    },
                    child: const Text('Delete Account', style: TextStyle(color: AppColors.secondaryColor)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
