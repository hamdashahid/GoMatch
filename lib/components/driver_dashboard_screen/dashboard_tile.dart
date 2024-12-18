import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color borderColor; // Added border color to indicate status

  const DashboardTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.borderColor, // Required border color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Adds spacing around the tile
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2), // Border with dynamic color
        borderRadius: BorderRadius.circular(8), // Rounded corners
        color: Colors.white, // Background color for the tile
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ], // Adds subtle shadow for better aesthetics
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black, // Adjust as per your color scheme
          ),
        ),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor),
        onTap: onTap,
      ),
    );
  }
}
