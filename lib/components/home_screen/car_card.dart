import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class CarCard extends StatelessWidget {
  final int index;
  final String carDetails;
  final String pickupTime;
  final String departureTime;
  final String driverPhone;
  final bool isKycVerified;
  final int malePassengers;
  final int femalePassengers;
  final int? selectedCarIndex;
  final int available;
  final Function(int) onCardTap;

  const CarCard({
    super.key,
    required this.index,
    required this.carDetails,
    required this.pickupTime,
    required this.departureTime,
    required this.driverPhone,
    required this.isKycVerified,
    required this.malePassengers,
    required this.femalePassengers,
    required this.selectedCarIndex,
    required this.available,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCardTap(index),
      child: Card(
        color: AppColors.primaryColor,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car,
                      size: 40, color: AppColors.secondaryColor),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(carDetails,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const SizedBox(height: 5),
                      Text("Pickup: $pickupTime",
                          style: const TextStyle(color: Colors.white)),
                      Text("Departs: $departureTime",
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (selectedCarIndex == index) ...[
                const Divider(color: Colors.white),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Colors.green),
                        const SizedBox(width: 5),
                        Text(driverPhone,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.verified,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          isKycVerified ? "Verified" : "Unverified",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isKycVerified
                                  ? Colors.green
                                  : Colors.redAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Male: $malePassengers",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Female: $femalePassengers",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Available Seats: $available",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add booking logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                    ),
                    child: const Text(
                      "Book Ride",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
