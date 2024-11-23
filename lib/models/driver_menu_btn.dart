import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DriverMenuBtn extends StatelessWidget {
  const DriverMenuBtn({
    super.key,
    required this.press,
    required this.isMenuOpen,
  });

  final VoidCallback press;
  final bool isMenuOpen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: press,
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          height: 40,
          width: 40,
          decoration: isMenuOpen
              ? null // No decoration when menu is open (transparent)
              : const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, 3),
                      blurRadius: 8,
                    )
                  ],
                ),
          child: Icon(
            isMenuOpen ? Icons.arrow_back : Icons.menu, // Toggle icon
            color: isMenuOpen ? Colors.white : Colors.white, // Adjust icon color
          ),
        ),
      ),
    );
  }
}
