import 'package:flutter/material.dart';
import 'package:gomatch/components/driver_side_drawer/driver_menu_item.dart';
import 'package:gomatch/utils/colors.dart';

class SideMenuTile extends StatelessWidget {
  const SideMenuTile({
    super.key,
    required this.menu,
    required this.press,
    required this.isActive,
  });

  final MenuItem menu; // Assuming you have a MenuItem class or model
  final VoidCallback press; // Press callback
  final bool isActive; // Is the menu item active

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Divider(
            color: AppColors.white,
            height: 1,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200), // Animation duration
          curve: Curves.easeInOut,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? AppColors.white : Colors.transparent,
            borderRadius: isActive ? const BorderRadius.all(Radius.circular(10)) : null,
          ),
          child: ListTile(
            onTap: press,
            leading: SizedBox(
              height: 34,
              width: 34,
              child: Icon(menu.icon, color: isActive ? AppColors.secondaryColor : Colors.white), // Default Flutter icon
            ),
            title: Text(
              menu.title,
              style: TextStyle(
                color: isActive ? AppColors.secondaryColor : Colors.white,
                fontFamily: 'Brand-Regular',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
