import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Brand-Bold', // Set your custom font here
          fontWeight: FontWeight.w600,
          fontSize: 16, // Optional: Adjust font size
        ),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: const TextStyle(
                fontFamily: 'Brand-Regular', // Set your custom font here
                fontSize: 14, // Optional: Adjust font size
              ),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor),
      onTap: onTap,
    );
  }
}

