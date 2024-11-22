import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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
  FocusNode dropOffFocusNode = FocusNode(); // Add this line

  int? selectedCarIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initialDropOffLocation != null) {
      dropOffTextEditingController.text = widget.initialDropOffLocation!;
    }
    if (widget.initialPickupLocation != null) {
      pickUpTextEditingController.text = widget.initialPickupLocation!;
    }
    if (widget.homeAddress != null) {
      homeTextEditingController.text = widget.homeAddress!;
    }
    if (widget.workAddress != null) {
      workTextEditingController.text = widget.workAddress!;
    }
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
                                    findPlace(val);
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
                          "Available Cars",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (widget.homeAddress != null &&
                        widget.homeAddress!.isNotEmpty) ...[
                      ListTile(
                        title: const Text(
                          "Home Address:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          widget.homeAddress!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.primaryColor),
                      const SizedBox(height: 10),
                    ],
                    if (widget.workAddress != null &&
                        widget.workAddress!.isNotEmpty) ...[
                      ListTile(
                        title: const Text(
                          "Work Address:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          widget.workAddress!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const Divider(color: AppColors.primaryColor),
                      const SizedBox(height: 10),
                    ],
                    // Wrap ListView with a bounded height
                    SizedBox(
                      height: 200, // Adjust the height as needed
                      child: ListView(
                        children: [
                          CarCard(
                            index: 0,
                            carDetails: "10-Seater, Male & Female",
                            pickupTime: "9:30 AM",
                            departureTime: "10:00 AM",
                            driverPhone: "+123456789",
                            isKycVerified: true,
                            malePassengers: 5,
                            femalePassengers: 3,
                            selectedCarIndex: selectedCarIndex,
                            available: 2,
                            pickup: pickUpTextEditingController.text,
                            dropoff: dropOffTextEditingController.text,
                            onCardTap: (int index) {
                              setState(() {
                                selectedCarIndex =
                                    selectedCarIndex == index ? null : index;
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => PaymentScreen(),
                                //   ),
                                // );
                              });
                            },
                          ),
                          CarCard(
                            index: 1,
                            carDetails: "10-Seater, Female Only",
                            pickupTime: "11:00 AM",
                            departureTime: "11:30 AM",
                            driverPhone: "+987654321",
                            isKycVerified: true,
                            malePassengers: 0,
                            femalePassengers: 7,
                            available: 3,
                            selectedCarIndex: selectedCarIndex,
                            pickup: pickUpTextEditingController.text,
                            dropoff: dropOffTextEditingController.text,
                            onCardTap: (int index) {
                              setState(
                                () {
                                  selectedCarIndex =
                                      selectedCarIndex == index ? null : index;
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => PaymentScreen(),
                                  //   ),
                                  // );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Button to navigate to the MapPage
                    ElevatedButton(
                      onPressed: () {
                        String pickupLocation =
                            pickUpTextEditingController.text;
                        String dropOffLocation =
                            dropOffTextEditingController.text;

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
                      child: const Text("Set Locations"),
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
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
    List<Location> locations = await locationFromAddress(location);
    if (locations.isNotEmpty) {
      double latitude = locations[0].latitude;
      double longitude = locations[0].longitude;
      // print("Pickup Location: $pickupGeoPoint");
      print("$latitude, $longitude");
      return GeoPoint(latitude: latitude, longitude: longitude);
    } else {
      throw Exception("Failed to convert location to GeoPoint");
    }
  }

  void findPlace(String placeName) async {
    // Your place finding logic here
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
