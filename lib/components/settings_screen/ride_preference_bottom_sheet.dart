import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class RidePreferencesBottomSheet {
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
              Text('Choose Ride Preference', style: TextStyle(fontSize: 18, color: Colors.white)),
              ListTile(
                title: const Text('Economy', style: TextStyle(color: AppColors.secondaryColor)),
                onTap: () {
                  // Handle selection
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Luxury', style: TextStyle(color: AppColors.secondaryColor)),
                onTap: () {
                  // Handle selection
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
