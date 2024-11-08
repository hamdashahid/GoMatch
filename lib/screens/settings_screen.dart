import 'package:flutter/material.dart';
import 'package:gomatch/components/settings_screen/delete_account_confirmation_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/help_support_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/logout_confirmation_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/notifications_settings_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/payment_methods_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/privacy_policy_bottom_sheet.dart';
import 'package:gomatch/components/settings_screen/settings_tile.dart'; 
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/components/settings_screen/ride_preference_bottom_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  static const String idScreen = "Settings";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          // Ride Sharing Settings
          SettingsTile(
            icon: Icons.local_taxi,
            title: 'Ride Preferences',
            subtitle: 'Economy, Luxury',
            onTap: () {
              RidePreferencesBottomSheet.show(context);
            },
          ),
          SettingsTile(
            icon: Icons.payment,
            title: 'Payment Methods',
            subtitle: 'Debit Card, EasyPaisa, JazzCash',
            onTap: () {
              PaymentMethodsBottomSheet.show(context);
            },
          ),
          SettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Push notifications',
            onTap: () {
              NotificationsSettingsBottomSheet.show(context);
            },
          ),
          
          SettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () {
              PrivacyPolicyBottomSheet.show(context);
            },
          ),
          SettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Contact us for help',
            onTap: () {
              HelpSupportBottomSheet.show(context);
            },
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              LogoutConfirmationBottomSheet.show(context);
            },
          ),
          SettingsTile(
            icon: Icons.delete,
            title: 'Delete my account',
            subtitle: 'Delete my account',
            onTap: () {
              DeleteAccountConfirmationBottomSheet.show(context);
            },
          ),
        ],
      ),
    );
  }
}
