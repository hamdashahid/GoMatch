import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/car_card.dart';
import 'package:gomatch/components/map_screen/available_seats.dart';
import 'package:gomatch/screens/payment_screen.dart';

class AvailableCarsScreen extends StatefulWidget {
  static const String idScreen = "AvailableCarsScreen";
  final String? pickup;
  final String? dropoff;
  String? price;
  AvailableCarsScreen({Key? key, this.pickup, this.dropoff, this.price})
      : super(key: key);

  @override
  _AvailableCarsScreenState createState() => _AvailableCarsScreenState();
}

class _AvailableCarsScreenState extends State<AvailableCarsScreen> {
  late Future<List<Map<String, dynamic>>> availableCarsFuture;
  int? selectedCarIndex;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, TextEditingController>> rides = [];
  List<Map<String, dynamic>> rideHistory = [];

  User? user;
  // final List<Map<String, TextEditingController>> rides = [];

  @override
  void initState() {
    super.initState();
    availableCarsFuture = fetchAvailableCars(widget.pickup!, widget.dropoff!);
  }

  Future<List<Map<String, dynamic>>> fetchPassengerRides(String uid) async {
    try {
      // Reference to the rides subcollection
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('passenger_profile')
          .doc(uid)
          .collection('rides')
          .orderBy('ride_time', descending: true) // Most recent rides first
          .get();

      for (var doc in ridesSnapshot.docs) {
        rideHistory.add(doc.data() as Map<String, dynamic>);
      }

      print("Fetched ${rideHistory.length} rides for passenger with UID: $uid");
    } catch (e) {
      print("Error fetching ride history: $e");
    }

    return rideHistory;
  }

  void handleSubmit() async {
    if (widget.pickup == "" || widget.dropoff == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the required fields")),
      );
      return;
    }

    final routeData = {
      "pickup_location": widget.pickup,
      "dropoff_location": widget.dropoff,
      "price": widget.price,
      "rides": rides.map((ride) {
        return {
          "pickup": ride["pickup"]?.text,
          "dropoff": ride["dropoff"]?.text,
          "price": ride["price"]?.text,
        };
      }).toList(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not authenticated")),
      );
      return;
    }

    String uid = user.uid;

    // Reference to the rides subcollection
    CollectionReference ridesCollection =
        _firestore.collection('passenger_profile').doc(uid).collection('rides');

    // Add the new ride data to the rides subcollection
    await ridesCollection.add(routeData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride added successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Available Cars")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: availableCarsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading cars"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No cars available"));
          } else {
            final cars = snapshot.data!;
            return ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return CarCard(
                  index: index,
                  carDetails:
                      "${car['vehicleName']} ${car['vehicleModel']} - ${car['vehicleColor']}",
                  pickupTime: car['start_pickup_time'] ?? "N/A",
                  departureTime: car['end_pickup_time'] ?? "N/A",
                  driverPhone: car['phone'] ?? "N/A",
                  isKycVerified: true, // Add logic to check KYC if applicable
                  malePassengers: 0, // Replace with actual data
                  femalePassengers: 0, // Replace with actual data
                  available: car['total_seats'] - car['booked_seats'].length ??
                      0, // Replace with actual data for available seats
                  price: car['price'] ?? "N/A", // Display price
                  selectedCarIndex: index == selectedCarIndex ? index : null,
                  onCardTap: (index) {
                    setState(() {
                      selectedCarIndex =
                          selectedCarIndex == index ? null : index;
                    });
                    // selectedCarIndex = selectedCarIndex == index ? null : index;
                    print("Tapped on car $index");
                    // Navigator.of(context)
                    //     .pop(); // Close bottom sheet after selection
                    print("Selected car: $selectedCarIndex");
                  },
                  pickup: widget.pickup!,
                  dropoff: widget.dropoff!,
                  onBookRide: (index) {
                    widget.price = car['price'] ?? "N/A";
                    handleSubmit();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvailableSeatsScreen(
                            driverUid: car['driverUid'],
                            // selectedCar: cars[index],
                            // price: car['price'] ?? "N/A",
                          ),
                        )
                        // MaterialPageRoute(
                        //   builder: (context) => PaymentScreen(
                        //     // selectedCar: cars[index],
                        //     price: car['price'] ?? "N/A",
                        //   ),
                        // ),
                        );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchAvailableCars(
      String pickup, String dropoff) async {
    List<Map<String, dynamic>> availableCars = [];

    try {
      // Fetch all drivers
      QuerySnapshot driversSnapshot =
          await FirebaseFirestore.instance.collection('driver_profile').get();

      for (var doc in driversSnapshot.docs) {
        Map<String, dynamic> driverData = doc.data() as Map<String, dynamic>;
        if (doc.exists && !driverData.containsKey('driverUid')) {
          // driverData['driverUid'] = doc.id;
          // driverData.add('driverUid', doc.id);
          doc.reference.update({'driverUid': doc.id});
        } else if (doc.exists && driverData.containsKey('driverUid')) {
          driverData['driverUid'] = doc.id;
        }

        if (doc.exists && !driverData.containsKey('available_seats')) {
          doc.reference.update({'available_seats': driverData['total_seats']});
        }
        // Check if stops contain both pickup and dropoff addresses
        List<dynamic> stops = driverData['stops'] ?? [];
        String dpickup = driverData['start_location'] ?? "";
        String ddropoff = driverData['end_location'] ?? "";
        bool hasPickup = stops.any((stop) => stop['stop_name'] == pickup) ||
            dpickup == pickup;
        bool hasDropoff = stops.any((stop) => stop['stop_name'] == dropoff) ||
            ddropoff == dropoff;
        // availableCars.add(driverData);

        if (hasPickup && hasDropoff) {
          print("Driver has both pickup and dropoff stops");
          availableCars.add(driverData);
        }
      }
    } catch (e) {
      print("Error fetching available cars: $e");
    }

    return availableCars;
  }
}
