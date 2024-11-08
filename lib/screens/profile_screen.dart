import 'package:flutter/material.dart';
import 'package:gomatch/components/profile_screen/dob_bottom_sheet.dart';
import 'package:gomatch/components/profile_screen/email_bottom_sheet.dart';
import 'package:gomatch/components/profile_screen/gender_selection_bottom_sheet.dart';
import 'package:gomatch/components/profile_screen/name_bottom_sheet.dart';
import 'package:gomatch/components/profile_screen/phone_bottom_sheet.dart';
import 'package:gomatch/components/profile_screen/profile_tile.dart';
import 'package:gomatch/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String idScreen = "Profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedGender = 'Unspecified';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        iconTheme:
            const IconThemeData(color: Colors.white), // Back button color
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        children: [
          ProfileTile(
            icon: Icons.account_box,
            title: 'Name',
            subtitle: 'Name',
            onTap: () {
              // Action when tile is clicked
              _openNameBottomSheet(context);
            },
          ),
          ProfileTile(
            icon: Icons.phone,
            title: 'Phone number',
            subtitle: '923038018095',
            onTap: () {
              // Action when tile is clicked
              _openPhoneNumberBottomSheet(context);
            },
          ),
          ProfileTile(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'abc@gmail.com',
            onTap: () {
              // Action when tile is clicked
              _openEmailBottomSheet(context);
            },
          ),
          ProfileTile(
            icon: Icons.person,
            title: 'Gender',
            subtitle: selectedGender!,
            onTap: () {
              // Open bottom sheet for gender selection
              _openGenderSelectionBottomSheet(context);
            },
          ),
          ProfileTile(
            icon: Icons.calendar_today,
            title: 'Date of birth',
            subtitle: '',
            onTap: () {
              // Action when tile is clicked
              _openDOBSelectionBottomSheet(context);
            },
          ),
        ],
      ),
    );
  }

  void _openGenderSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return GenderSelectionBottomSheet(
          selectedGender: selectedGender,
          onGenderSelected: (newGender) {
            setState(() {
              selectedGender = newGender;
            });
          },
        );
      },
    );
  }

  void _openNameBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to move when the keyboard appears
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjust bottom padding for keyboard
          ),
          child: NameBottomSheet(
            currentName: 'Name', // Pass current name
            onNameSelected: (newName) {
              // Handle name change
            },
          ),
        );
      },
    );
  }

  void _openPhoneNumberBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Enables scrolling to move up when keyboard appears
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjust bottom padding for keyboard
          ),
          child: PhoneNumberBottomSheet(
            currentPhoneNumber: '923038018095', // Pass current phone number
            onPhoneNumberSelected: (newPhone) {
              // Handle phone number change
            },
          ),
        );
      },
    );
  }

  void _openEmailBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // This allows the bottom sheet to move when the keyboard appears
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjust bottom padding when keyboard is open
          ),
          child: EmailBottomSheet(
            currentEmail: 'abc@gmail.com', // Pass current email
            onEmailSelected: (newEmail) {
              setState(() {
                // Update the email here
              });
            },
          ),
        );
      },
    );
  }

  void _openDOBSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: AppColors.primaryColor,
      builder: (BuildContext context) {
        return DOBSelectionBottomSheet(
          currentDOB: DateTime(1995, 1, 1), // Pass current date of birth
          onDOBSelected: (newDOB) {
            setState(() {
              // Update the date of birth here
            });
          },
        );
      },
    );
  }
}
