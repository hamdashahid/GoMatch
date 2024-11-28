import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/screens/payment_screen.dart';
import 'package:gomatch/utils/colors.dart';

class CarCard extends StatelessWidget {
  final String DriverUid;
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
  final Function(int) onBookRide;
  final String pickup;
  final String dropoff;
  final String price;

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
    required this.price,
    required this.onBookRide,
    required this.DriverUid,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCardTap(index),
      child: Card(
        color: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: selectedCarIndex == index
              ? BorderSide(color: AppColors.secondaryColor, width: 5)
              : BorderSide.none,
        ),
        margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15),
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
                      "Price: $price",
                      style: const TextStyle(color: Colors.white),
                    ),
                    // Text(
                    //   "Female: $femalePassengers",
                    //   style: const TextStyle(color: Colors.white),
                    // ),

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
                      onBookRide(index);
                      // Add booking logic
                      // _showCarpoolBottomSheet(context);
                      fetchDriverAndShowBottomSheet(context, DriverUid);
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

  void fetchDriverAndShowBottomSheet(
      BuildContext context, String driverUid) async {
    try {
      // Fetch driver data from Firestore
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('driver_profile') // Replace with your collection name
          .doc(driverUid)
          .get();

      if (driverSnapshot.exists) {
        Map<String, dynamic> driverData =
            driverSnapshot.data() as Map<String, dynamic>;
        // Show the bottom sheet with the fetched driver data
        _showCarpoolBottomSheet(context, driverData);
      } else {
        // Handle the case where the driver does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver data not found.')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching driver data: $e')),
      );
    }
  }

  // Function to show the bottom sheet of Car Button
  void _showCarpoolBottomSheet(
      BuildContext context, Map<String, dynamic> driverData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
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
                      initialChildSize: 0.6,
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
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Driver Details",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.person,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(driverData['name'] ?? 'N/A'),
                                    subtitle:
                                        Text('Phone: ${driverData['phone']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.directions_car,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(
                                      '${driverData['vehicleName']} - ${driverData['vehicleColor']}',
                                    ),
                                    subtitle: Text(
                                        'Model: ${driverData['vehicleModel']}'),
                                    trailing: Text(
                                        'Seats: ${driverData['available_seats']}/${driverData['total_seats']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.currency_exchange,
                                        color: AppColors.secondaryColor),
                                    title: const Text('Price'),
                                    subtitle:
                                        Text('PKR ${driverData['price']}'),
                                  ),
                                  const Divider(),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Route Details",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: AppColors.secondaryColor),
                                    title: Text(
                                        'From: ${driverData['start_location']['location']}'),
                                    subtitle: Text(
                                        'To: ${driverData['end_location']['location']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.timer,
                                        color: AppColors.secondaryColor),
                                    title: Text(
                                        'Pickup Time: ${driverData['start_pickup_time']}'),
                                    subtitle: Text(
                                        'Drop-off Time: ${driverData['end_pickup_time']}'),
                                  ),
                                  const Divider(),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Stops",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(driverData['stops'].length,
                                      (index) {
                                    final stop = driverData['stops'][index];
                                    return ListTile(
                                      leading: const Icon(Icons.stop_circle,
                                          color: AppColors.secondaryColor),
                                      title: Text(
                                          stop['stop_name'] ?? 'Unknown Stop'),
                                      subtitle: Text(
                                          'Arrival Time: ${stop['arrival_time']}'),
                                    );
                                  }),
                                  const Divider(),
                                  // Center(
                                  //   child: ElevatedButton(
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor:
                                  //           AppColors.secondaryColor,
                                  //       foregroundColor: AppColors.primaryColor,
                                  //     ),
                                  //     onPressed: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => PaymentScreen(
                                  //             price: driverData['price'],
                                  //           ),
                                  //         ),
                                  //       );
                                  //     },
                                  //     child: const Text('Confirm Booking'),
                                  //   ),
                                  // ),
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
