import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class RideHistoryTile extends StatelessWidget {
  final String date;
  final String pickupLocation;
  final String dropLocation;
  final String fare;
  final bool cancelled;

  const RideHistoryTile({
    super.key,
    required this.date,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    this.cancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16, // Increase font size for the date
              fontWeight: FontWeight.bold,
              color:AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 4), // Spacing between date and location rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Pickup Circle
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.blue, // Pickup circle color
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(pickupLocation),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Drop-off Circle
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.green, // Drop-off circle color
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(dropLocation),
                    ],
                  ),
                ],
              ),
              Text(fare, style: const TextStyle(fontWeight: FontWeight.bold,color:AppColors.primaryColor)),
            ],
          ),
          if (cancelled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "You cancelled",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          const Divider(),
        ],
      ),
    );
  }
}
