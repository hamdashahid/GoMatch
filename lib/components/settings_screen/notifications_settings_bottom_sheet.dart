import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class NotificationsSettingsBottomSheet {
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
              Text('Notifications', style: TextStyle(fontSize: 18, color: Colors.white)),
              SwitchListTile(
                title: const Text('Enable Push Notifications', style: TextStyle(color: Colors.white)),
                value: true, // Example value, use actual state
                onChanged: (bool value) {
                  // Handle switch change
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
