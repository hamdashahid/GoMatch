import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/screens/payment_screen.dart';
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
  final String pickup;
  final String dropoff;

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
    required this.pickup,
    required this.dropoff,
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
                      _showCarpoolBottomSheet(context);
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

  // Function to show the bottom sheet of Car Button
  void _showCarpoolBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context)
                    .pop(); // Close bottom sheet on outside tap
              },
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {}, // Prevent dismissing when tapping inside
                    child: DraggableScrollableSheet(
                      expand: true,
                      initialChildSize: 0.5,
                      minChildSize: 0.5,
                      maxChildSize: 1,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Add Home and Add Work options
                                  ListTile(
                                    leading: const Icon(Icons.my_location,color: AppColors.secondaryColor),
                                    title: const Text('Pickup Location'),
                                    subtitle:Text(pickup),
                                    
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_pin,
                                        color: AppColors.primaryColor),
                                    title: const Text('Dropoff Location'),
                                    subtitle: Text(dropoff),

                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: AppColors.secondaryColor),
                                    title: const Text('Set Pickup and Dropoff'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            initialDropOffLocation:
                                                'Set Dropoff',

                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.payment,
                                        color: Colors.green),
                                    title: const Text('Confirm Payment'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PaymentScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // Button to set pickup and dropoff locations

}
