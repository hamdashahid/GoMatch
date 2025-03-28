import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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
  String ride = "";
  User? user;
  // final List<Map<String, TextEditingController>> rides = [];

  @override
  void initState() {
    super.initState();
    availableCarsFuture =
        fetchAvailableCars(widget.pickup ?? "", widget.dropoff ?? "");
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

  Future<void> sendNotificationToDriver(
      String token, String title, String message) async {
    try {
      // final FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Send FCM message
      // await messaging.sendMessage(
      //   to: token,
      //   data: {
      //     'title': title,
      //     'body': message,
      //   },
      // );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> bookRide(String driverId, String passengerId, String pickup,
      String destination) async {
    print("Driver ID: $driverId");
    try {
      // Create ride request document in Firestore
      var doc =
          FirebaseFirestore.instance.collection('driver_profile').doc(driverId);
      var rideRequestRef = await doc.collection('ride_requests').add({
        'driverId': driverId,
        'passengerId': passengerId,
        'pickupLocation': pickup,
        'destination': destination,
        'status': 'pending', // Default status
        'createdAt': FieldValue.serverTimestamp(),
      });
      ride = rideRequestRef.id;
      waitForDriverResponse(driverId, rideRequestRef.id);
    } catch (e) {
      print('Error sending ride request: $e');
    }
  }

  Future<void> waitForDriverResponse(
      String driverId, String rideRequestId) async {
    try {
      DocumentReference rideRequestRef = FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(driverId)
          .collection('ride_requests')
          .doc(rideRequestId);

      // Show a dialog to the user to wait for the driver's response
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Waiting for driver's response"),
            content: const Text(
                "Please wait while the driver accepts your ride request."),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

      // Listen for changes in the ride request document
      rideRequestRef.snapshots().listen((snapshot) {
        if (snapshot.exists) {
          String status =
              (snapshot.data() as Map<String, dynamic>)['status'] ?? 'pending';
          if (status == 'accepted') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Ride request was accepted by the driver")),
            );
            Navigator.of(context).pop(); // Close the waiting dialog
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvailableSeatsScreen(
                  driverUid: driverId,
                  price: widget.price ?? "N/A",
                  rideId: rideRequestId,
                ),
              ),
            );
          } else if (status == 'rejected') {
            Navigator.of(context).pop(); // Close the waiting dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Ride request was rejected by the driver")),
            );
          }
        }
      });

      // Wait for 1 minute before checking the status
      await Future.delayed(const Duration(minutes: 3));

      // Check the status after 1 minute
      DocumentSnapshot rideRequestSnapshot = await rideRequestRef.get();
      if (rideRequestSnapshot.exists) {
        String status =
            (rideRequestSnapshot.data() as Map<String, dynamic>)['status'] ??
                'pending';
        if (status == 'pending') {
          Navigator.of(context).pop(); // Close the waiting dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Ride request timed out. Please try again.")),
          );
        }
      }
    } catch (e) {
      print('Error waiting for driver response: $e');
      Navigator.of(context).pop(); // Close the waiting dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  void handleSubmit() async {
    if (widget.pickup == "" || widget.dropoff == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the required fields")),
      );
      return;
    }

    final routeData = {
      "pickup_location": widget.pickup ?? "",
      "dropoff_location": widget.dropoff ?? "",
      "price": widget.price ?? "N/A",
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
                  DriverUid: car['driverUid'],
                  index: index,
                  carDetails:
                      "${car['vehicleName']} ${car['vehicleModel']} - ${car['vehicleColor']}",
                  pickupTime: car['start_pickup_time'] ?? "N/A",
                  departureTime: car['end_pickup_time'] ?? "N/A",
                  driverPhone: car['phone'] ?? "N/A",
                  isKycVerified: true, // Add logic to check KYC if applicable
                  malePassengers: 0, // Replace with actual data
                  femalePassengers: 0, // Replace with actual data
                  available: /*car['vehicleSeat'] - car['booked_seats'].length ??*/
                      (car['available_seats'] ?? 0) + 1 ??
                          10, // Replace with actual data for available seats
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
                  pickup: widget.pickup ?? "",
                  dropoff: widget.dropoff ?? "",
                  onBookRide: (index) {
                    widget.price = car['price'] ?? "N/A";
                    handleSubmit();
                    user = _auth.currentUser;
                    if (user != null) {
                      bookRide(car['driverUid'], user!.uid, widget.pickup ?? "",
                          widget.dropoff ?? "");
                    } else {
                      return;
                    }
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => AvailableSeatsScreen(
                    //         driverUid: car['driverUid'],
                    //         price: car['price'] ?? "N/A",
                    //       ),
                    //     ));
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
    const double maxDistance = 5.0; // Maximum distance in kilometers

    try {
      // Fetch all drivers from Firestore
      bool stopmatch = false;
      bool pickupmatch = false;
      bool dropoffmatch = false;
      QuerySnapshot driversSnapshot =
          await FirebaseFirestore.instance.collection('driver_profile').get();

      for (var doc in driversSnapshot.docs) {
        Map<String, dynamic> driverData = doc.data() as Map<String, dynamic>;

        // Extract driver's location data
        Map<String, dynamic> startLocation = driverData['start_location'] ?? {};
        Map<String, dynamic> endLocation = driverData['end_location'] ?? {};
        List stops = driverData['stops'] ?? [];

        // Convert pickup and dropoff to GeoPoints
        GeoPoint userPickupPoint = await convertToGeoPoint(pickup);
        GeoPoint userDropoffPoint = await convertToGeoPoint(dropoff);

        // Calculate distances to driver's start and end locations
        double driverPickupDistance = calculateDistance(userPickupPoint,
            GeoPoint(startLocation['latitude'], startLocation['longitude']));
        double driverDropoffDistance = calculateDistance(userDropoffPoint,
            GeoPoint(endLocation['latitude'], endLocation['longitude']));
        pickupmatch = calculateDistance(
                userPickupPoint,
                GeoPoint(
                    startLocation['latitude'], startLocation['longitude'])) <=
            maxDistance;
        dropoffmatch = calculateDistance(userDropoffPoint,
                GeoPoint(endLocation['latitude'], endLocation['longitude'])) <=
            maxDistance;
        // Compare stops' distances with user's destination
        int closestStopIndex = -1;
        double closestDistance = double.infinity;
        String closestType =
            ""; // To track whether it's a stop or the driver's end location

        // Check each stop
        for (int i = 0; i < stops.length; i++) {
          Map<String, dynamic> stop = stops[i];
          double stopLat = stop['latitude'] ?? 0.0;
          double stopLon = stop['longitude'] ?? 0.0;

          if (stopLat == 0.0 || stopLon == 0.0) continue; // Skip invalid stops

          double stopDropoffDistance =
              calculateDistance(userDropoffPoint, GeoPoint(stopLat, stopLon));
          stopmatch =
              calculateDistance(userDropoffPoint, GeoPoint(stopLat, stopLon)) <=
                  maxDistance;
          // Check if this stop is closer than the current closest destination
          if (stopDropoffDistance < closestDistance) {
            closestDistance = stopDropoffDistance;
            closestStopIndex = i;
            closestType = "stop";
          }
        }

        // Compare the closest stop's distance with the driver's dropoff distance
        if (driverDropoffDistance < closestDistance) {
          closestDistance = driverDropoffDistance;
          closestType = "driver_destination";
        }

        // Add the driver to available cars based on the closest destination
        if (closestDistance <= maxDistance) {
          if (closestType == "stop") {
            driverData['price'] = stops[closestStopIndex]
                ['stop_price']; // Use stop-specific price
            print(
                "Closest match is a stop for driver: ${driverData['driverUid']}");
          } else if (closestType == "driver_destination") {
            driverData['price'] = driverData['price']; // Use driver's end price
            print(
                "Closest match is the driver's destination for driver: ${driverData['driverUid']}");
          }
        }
        if (pickupmatch && dropoffmatch || stopmatch) {
          availableCars.add(driverData);
        }
      }
    } catch (e) {
      print("Error fetching available cars: $e");
    }

    print("Available Cars List: $availableCars");
    return availableCars;
  }

  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371.0; // Earth's radius in kilometers

    double lat1 = point1.latitude;
    double lon1 = point1.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    print("Distance: ${earthRadius * c}");
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<GeoPoint> convertToGeoPoint(String location) async {
    // Using the geocoding package to convert location string to GeoPoint
    List<Location> locations = await locationFromAddress(location);
    if (locations.isNotEmpty) {
      double latitude = locations[0].latitude;
      double longitude = locations[0].longitude;
      // print("Pickup Location: $pickupGeoPoint");
      // print("$latitude, $longitude");
      return GeoPoint(latitude, longitude);
    } else {
      throw Exception("Failed to convert location to GeoPoint");
    }
  }
}
