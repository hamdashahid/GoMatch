import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:gomatch/Assistants/requestAssistant.dart';
import 'package:gomatch/configMaps.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:gomatch/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:gomatch/utils/colors.dart';
import 'car_card.dart'; // Assuming CarCard is a widget located here.
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:gomatch/models/address.dart' as ad;

class SearchScreen extends StatefulWidget {
  static const String idScreen = "SearchScreen";

  final String? initialDropOffLocation;
  final String? initialPickupLocation;
  final String? homeAddress;
  final String? workAddress;
  const SearchScreen(
      {Key? key,
      this.initialDropOffLocation,
      this.initialPickupLocation,
      this.homeAddress,
      this.workAddress})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  TextEditingController homeTextEditingController = TextEditingController();
  TextEditingController workTextEditingController = TextEditingController();
  // TextEditingController nameTextEditingController = TextEditingController();
  // TextEditingController phoneTextEditingController = TextEditingController();
  FocusNode dropOffFocusNode = FocusNode(); // Add this line
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, TextEditingController>> rides = [];
  User? user;

  @override
  void initState() {
    super.initState();
    if (widget.initialDropOffLocation != null) {
      dropOffTextEditingController.text = widget.initialDropOffLocation!;
    }
    if (widget.initialPickupLocation != null) {
      pickUpTextEditingController.text = widget.initialPickupLocation!;
    }
    // if (widget.homeAddress != null) {
    //   homeTextEditingController.text = widget.homeAddress!;
    // }
    // if (widget.workAddress != null) {
    //   workTextEditingController.text = widget.workAddress!;
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(dropOffFocusNode);
    });

    if (Provider.of<AppData>(context, listen: false).pickUpLocation == null &&
        pickUpTextEditingController.text.isEmpty) {
      setState(() {
        // pickUpTextEditingController.text = await _getCurrentLocation();
        updatePickUpLocation("");
      });
      // pickUpTextEditingController.text = _getCurrentLocation();
    }
    user = _auth.currentUser;
    if (user != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      firestore.DocumentSnapshot userDoc =
          await _firestore.collection('passenger_profile').doc(user?.uid).get();
      if (userDoc.exists) {
        setState(() {
          // workTextEditingController.text = userDoc['home_address'] ?? '';
          // homeTextEditingController.text = userDoc['work_address'] ?? '';
          var userData = userDoc.data() as Map<String, dynamic>?;
          workTextEditingController.text =
              userData?.containsKey('work_address') == true
                  ? userData!['work_address']
                  : '';
          homeTextEditingController.text =
              userData?.containsKey('home_address') == true
                  ? userData!['home_address']
                  : '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  void updatePickUpLocation(String newLocation) async {
    if (newLocation.isEmpty) {
      newLocation = await _getCurrentLocation();
    }
    pickUpTextEditingController.text = newLocation;
  }

  @override
  void dispose() {
    dropOffFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation?.placeName ?? "";
    pickUpTextEditingController.text = placeAddress;
    // TextEditingController homeaddressController = TextEditingController();
    // TextEditingController workaddressController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Search Section (Pick-up & Drop-off locations)
              Container(
                height: 215.0,
                decoration: const BoxDecoration(
                  color: AppColors.lightPrimary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 15.0),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const Center(
                            child: Text(
                              "Set Drop Off",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontFamily: "Brand-Bold",
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          const Icon(Icons.my_location_rounded,
                              color: Colors.green),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Location",
                                    fillColor: Colors.white60,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 11.0,
                                      vertical: 8.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          const Icon(Icons.location_pin, color: Colors.red),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: TextField(
                                  onChanged: (val) {
                                    print("TextField changed with value: $val");
                                    // findPlace(val);
                                  },
                                  controller: dropOffTextEditingController,
                                  focusNode: dropOffFocusNode,
                                  decoration: const InputDecoration(
                                    hintText: "Where to?",
                                    fillColor: Colors.white60,
                                    filled: true,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 11.0,
                                      vertical: 8.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Center(
                        child: const Text(
                          "Saved Addresses",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: homeTextEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Home Address',
                        hintText: 'Enter home address',
                      ),
                    ),
                    // const Divider(color: AppColors.primaryColor),
                    const SizedBox(height: 20),
                    // ],
                    // if (widget.workAddress != null &&
                    //     widget.workAddress!.isNotEmpty) ...[
                    TextFormField(
                      controller: workTextEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Work Address',
                        hintText: 'Enter work address',
                      ),
                      // Text('Your work address'),
                      // onTap: () {
                      //   _showAddressOptionsDialog(context, 'work');
                      // },
                    ),
                    // const Divider(color: AppColors.primaryColor),
                    const SizedBox(height: 10),
                    // ],
                    // Button to navigate to the MapPage
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        backgroundColor: AppColors.secondaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 10.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      onPressed: () {
                        String pickupLocation =
                            pickUpTextEditingController.text;
                        String dropOffLocation =
                            dropOffTextEditingController.text;
                        saveProfile(context);
                        // Send pickup and drop-off locations to the MapPage
                        convertToGeoPoint(pickupLocation)
                            .then((pickupGeoPoint) {
                          convertToGeoPoint(dropOffLocation).then(
                            (dropOffGeoPoint) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPage(
                                    pickupLocation: pickupGeoPoint,
                                    destinationLocation: dropOffGeoPoint,
                                    pickupAddress: pickupLocation,
                                    destinationAddress: dropOffLocation,
                                  ),
                                ),
                              );
                            },
                          ).catchError((error) {
                            // Handle error for drop-off location conversion
                            print("Error converting drop-off location: $error");
                          });
                        }).catchError((error) {
                          // Handle error for pickup location conversion
                          print("Error converting pickup location: $error");
                        });
                      },
                      child: const Text("Set Locations",
                          style: TextStyle(
                            // fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveProfile(BuildContext context) async {
    try {
      // Collecting all the input data
      final verificationData = {
        'home_address': homeTextEditingController.text,
        'work_address': workTextEditingController.text,
      };

      // Saving to Firestore under the current user's UID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is not authenticated")),
        );
        return;
      }

      String uid = user.uid;
      await firestore.FirebaseFirestore.instance
          .collection('passenger_profile')
          .doc(uid)
          .set(verificationData, firestore.SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data stored successfully!")),
      );
      return;
    } catch (e) {
      print("Error saving driver profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving pasenger profile: $e")),
      );
    }
  }

  // Function to get current location if pickupLocation is not provided
  Future<String> _getCurrentLocation() async {
    // Request permission to access location
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return "";
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Update the pickup location with the current positionge
    return getAddressFromCoordinates(position.latitude, position.longitude);
  }

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
      return "Error in getting address";
    }
  }

  Future<GeoPoint> convertToGeoPoint(String location) async {
    // Using the geocoding package to convert location string to GeoPoint
    List<geocoding.Location> locations =
        await geocoding.locationFromAddress(location);
    if (locations.isNotEmpty) {
      double latitude = locations[0].latitude;
      double longitude = locations[0].longitude;
      // print("Pickup Location: $pickupGeoPoint");
      // print("$latitude, $longitude");
      return GeoPoint(latitude: latitude, longitude: longitude);
    } else {
      throw Exception("Failed to convert location to GeoPoint");
    }
  }

  void calculateAndDisplayDistance(
      GeoPoint startPoint, GeoPoint endPoint, RoadInfo roadInfo) async {
    double distance = roadInfo.distance!; // distance in kilometers

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Route Distance"),
          content: Text(
              "The distance between the points is ${distance.toStringAsFixed(2)} km."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
