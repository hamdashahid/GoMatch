import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gomatch/Assistants/requestAssistant.dart';
import 'package:gomatch/configMaps.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:provider/provider.dart';
import 'package:gomatch/utils/colors.dart';
import 'car_card.dart'; // Assuming CarCard is a widget located here.
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class SearchScreen extends StatefulWidget {
  final String? initialDropOffLocation;
  const SearchScreen({Key? key, this.initialDropOffLocation}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  FocusNode dropOffFocusNode = FocusNode(); // Add this line

  int? selectedCarIndex;

  @override
  void initState() {
    super.initState();
    if (widget.initialDropOffLocation != null) {
      dropOffTextEditingController.text = widget.initialDropOffLocation!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(dropOffFocusNode);
    });
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
      body: Column(
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
              padding: const EdgeInsets.only(
                left: 25.0,
                top: 20.0,
                right: 25.0,
                bottom: 20.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back,
                            color: AppColors.primaryColor),
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
                  // Pickup Location
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
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  // Drop-off Location
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
                                contentPadding: EdgeInsets.only(
                                  left: 11.0,
                                  top: 8.0,
                                  bottom: 8.0,
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
          const SizedBox(height: 20),
          // Car Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Available Cars",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    (Provider.of<AppData>(context).pickUpLocation != null)
                        ? Provider.of<AppData>(context)
                            .pickUpLocation!
                            .placeName
                        : "Home Address",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.primaryColor),
                  // Display available cars
                  Expanded(
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
                          onCardTap: (int index) {
                            setState(() {
                              selectedCarIndex =
                                  selectedCarIndex == index ? null : index;
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
                          onCardTap: (int index) {
                            setState(() {
                              selectedCarIndex =
                                  selectedCarIndex == index ? null : index;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Button to navigate to the MapPage
                  ElevatedButton(
                    onPressed: () {
                      String pickupLocation = pickUpTextEditingController.text;
                      String dropOffLocation =
                          dropOffTextEditingController.text;

                      // Send pickup and drop-off locations to the MapPage
                      convertToGeoPoint(pickupLocation).then((pickupGeoPoint) {
                        convertToGeoPoint(dropOffLocation).then(
                          (dropOffGeoPoint) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPage(
                                  pickupLocation: pickupGeoPoint,
                                  destinationLocation: dropOffGeoPoint,
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
          ),
        ],
      ),
    );
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
}
