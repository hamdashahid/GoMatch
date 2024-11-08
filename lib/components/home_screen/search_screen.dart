import 'package:flutter/material.dart';
import 'package:gomatch/Assistants/requestAssistant.dart';
import 'package:gomatch/configMaps.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:provider/provider.dart';
import 'package:gomatch/utils/colors.dart';
import 'car_card.dart'; // Assuming CarCard is a widget located here.

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

  // State variable for selected car
  int? selectedCarIndex;
  @override
  void initState() {
    super.initState();
    // Set the drop-off text field with the passed location
    if (widget.initialDropOffLocation != null) {
      dropOffTextEditingController.text = widget.initialDropOffLocation!;
    }
    // Request focus on the drop-off TextField
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(dropOffFocusNode);
    });
  }

  @override
  void dispose() {
    dropOffFocusNode.dispose(); // Dispose the FocusNode when the widget is disposed
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
          // The top search section (Pick-up & Drop-off locations)
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
                              focusNode: dropOffFocusNode, //focus line
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

                  // Dropdowns for Pickup Location and Destination

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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void findPlace(String placeName) async {
    print("findPlace called with: $placeName"); // Debugging line

    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:pk";
      var res = await Requestassistant.getRequest(autoCompleteUrl);
      if (res == "failed") {
        return;
      }
      print("Places Predictions Response :: ");
      print(res);
    }
  }
}
