import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class PaymentMethodsBottomSheet {
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
              Text('Payment Methods', style: TextStyle(fontSize: 18, color: Colors.white)),
              ListTile(
                title: const Text('Add New Card', style: TextStyle(color: AppColors.secondaryColor)),
                onTap: () {
                  // Handle adding new card
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Remove Card', style: TextStyle(color: AppColors.secondaryColor)),
                onTap: () {
                  // Handle removing a card
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
