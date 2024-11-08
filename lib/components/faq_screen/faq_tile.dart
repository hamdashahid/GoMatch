import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class FAQTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const FAQTile({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor),
      onTap: onTap,
    );
  }
}
