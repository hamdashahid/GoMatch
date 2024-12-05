import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:gomatch/components/driver_dashboard_screen/dashboard_tile.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:colornames/colornames.dart';

class DriverDashboardScreen extends StatefulWidget {
  static const String idScreen = "DriverDashboardScreen";

  @override
  _DriverDashboardScreenState createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  // TextEditingController cnicController = TextEditingController();
  MaskedTextController cnicController =
      MaskedTextController(mask: '00000-0000000-0');
  // TextEditingController licenseController = TextEditingController();
  TextEditingController licenseController = MaskedTextController(mask: '00000');
  TextEditingController vehicleModelController =
      MaskedTextController(mask: '0000');

  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleColorController = TextEditingController();
  TextEditingController vehicleNameController = TextEditingController();
  TextEditingController startLocationController = TextEditingController();
  TextEditingController endLocationController = TextEditingController();
  TextEditingController vehicleSeatcontroller =
      MaskedTextController(mask: '0000');
  // final TextEditingController startLocationController = TextEditingController();
  final TextEditingController startPickupTimeController =
      TextEditingController();
  // final TextEditingController endLocationController = TextEditingController();
  final TextEditingController endPickupTimeController = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final List<Map<String, TextEditingController>> stops = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> vehicleNames = [
    'Toyota Corolla',
    'Honda Civic',
    'Suzuki Alto',
    'Suzuki Cultus',
    'Toyota Yaris',
    'Honda City',
    'Suzuki Wagon R',
  ]; // Hardcoded suggestions for Vehicle Name

  final List<String> vehicleModels = [
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
  ];
  User? user;

  void showBottomSheet(BuildContext context, String title, Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8, // Adjust the initial height of the bottom sheet
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20.0),
                  content,
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        saveDriverProfile(context, title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$title data stored successfully!',
                              style: const TextStyle(
                                  color: AppColors.primaryColor),
                            ),
                            backgroundColor: AppColors.secondaryColor,
                          ),
                        );
                        Navigator.pop(context); // Close the bottom sheet
                      }
                    },
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 18.0,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void saveDriverProfile(BuildContext context, String title) async {
    try {
      // Collecting all the input data
      if (title == "Verification") {
        final verificationData = {
          'cnic': cnicController.text.trim(),
          'license': licenseController.text.trim(),
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
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(uid)
            .set(verificationData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Verification data stored successfully!")),
        );
        return;
      } else if (title == "Vehicle Registration") {
        final vehicleRegistrationData = {
          'vehicleNumber': vehicleNumberController.text.trim(),
          'vehicleModel': vehicleModelController.text.trim(),
          'vehicleColor': vehicleColorController.text.trim(),
          'vehicleName': vehicleNameController.text.trim(),
          'vehicleSeat': int.parse(vehicleSeatcontroller.text.trim()),
          'available_seats': int.parse(vehicleSeatcontroller.text.trim()),
          'booked_seats': [],
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
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(uid)
            .set(vehicleRegistrationData, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Vehicle registration data stored successfully!")),
        );
        return;
      } else if (title == "Routes") {
        handleSubmit();
      }
    } catch (e) {
      print("Error saving driver profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving driver profile: $e")),
      );
    }
  }

  void addStop() {
    setState(() {
      // GeoPoint temp = GeoPoint(0.0, 0.0);
      stops.add({
        "name": TextEditingController(),
        "time": TextEditingController(),
        "stop_price": TextEditingController(),
      });
    });
  }

  void removeStop(int index) {
    setState(() {
      stops.removeAt(index);
    });
  }

  Future<void> storeToFirestore(Map<String, dynamic> data) async {
    try {
      // Get the current user's UID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User is not authenticated")),
        );
        return;
      }

      String uid = user.uid;

      // Reference to the driver_profile collection, using UID as document ID
      await _firestore
          .collection('driver_profile')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data stored successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to store data: $e")),
      );
    }
  }

  Future<GeoPoint> convertToGeoPoint(String? location) async {
    // Using the geocoding package to convert location string to GeoPoint
    List<Location> locations = await locationFromAddress(location!);
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

  void handleSubmit() {
    if (startLocationController.text.isEmpty ||
        startPickupTimeController.text.isEmpty ||
        endLocationController.text.isEmpty ||
        endPickupTimeController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all the required fields")),
      );
      return;
    }
    GeoPoint pick = GeoPoint(0.0, 0.0);
    GeoPoint drop = GeoPoint(0.0, 0.0);
    Future<List<Map<String, dynamic>>> getStopsData() async {
      pick = await convertToGeoPoint(startLocationController.text);
      drop = await convertToGeoPoint(endLocationController.text);
      return await Future.wait(stops.map((stop) async {
        GeoPoint temp = await convertToGeoPoint(stop["name"]?.text);
        return {
          "stop_name": stop["name"]?.text,
          "arrival_time": stop["time"]?.text,
          "stop_price": stop["stop_price"]?.text,
          "latitude": temp.latitude,
          "longitude": temp.longitude,
        };
      }).toList());
    }

    getStopsData().then((stopsData) {
      final routeData = {
        "start_location": {
          "location": startLocationController.text,
          "latitude": pick.latitude,
          "longitude": pick.longitude,
        },
        "start_pickup_time": startPickupTimeController.text,
        "end_location": {
          "location": endLocationController.text,
          "latitude": drop.latitude,
          "longitude": drop.longitude,
        },
        "end_pickup_time": endPickupTimeController.text,
        "price": priceController.text,
        "total_seats": vehicleSeatcontroller.text,
        "stops": stopsData,
        "timestamp": FieldValue.serverTimestamp(),
      };

      storeToFirestore(routeData);
    });
  }

  @override
  void dispose() {
    startLocationController.dispose();
    startPickupTimeController.dispose();
    endLocationController.dispose();
    endPickupTimeController.dispose();
    for (var stop in stops) {
      stop["name"]?.dispose();
      stop["time"]?.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('driver_profile').doc(user?.uid).get();
      if (userDoc.exists) {
        setState(() {
          name.text = userDoc['name'] ?? '';
          phone.text = userDoc['phone'] ?? '';
          var userData = userDoc.data() as Map<String, dynamic>?;
          cnicController.text =
              userData?.containsKey('cnic') == true ? userData!['cnic'] : '';
          licenseController.text = userData?.containsKey('license') == true
              ? userData!['license']
              : '';
          vehicleNumberController.text =
              userData?.containsKey('vehicleNumber') == true
                  ? userData!['vehicleNumber']
                  : '';
          vehicleModelController.text =
              userData?.containsKey('vehicleModel') == true
                  ? userData!['vehicleModel']
                  : '';
          vehicleColorController.text =
              userData?.containsKey('vehicleColor') == true
                  ? userData!['vehicleColor']
                  : '';
          vehicleNameController.text =
              userData?.containsKey('vehicleName') == true
                  ? userData!['vehicleName']
                  : '';
          vehicleSeatcontroller.text =
              userData?.containsKey('vehicleSeat') == true
                  ? userData!['vehicleSeat'].toString()
                  : '';
          startLocationController.text =
              userData?.containsKey('start_location') == true
                  ? userData!['start_location']['location']
                  : '';
          endLocationController.text =
              userData?.containsKey('end_location') == true
                  ? userData!['end_location']['location']
                  : '';
          startPickupTimeController.text =
              userData?.containsKey('start_pickup_time') == true
                  ? userData!['start_pickup_time']
                  : '';
          endPickupTimeController.text =
              userData?.containsKey('end_pickup_time') == true
                  ? userData!['end_pickup_time']
                  : '';
          priceController.text =
              userData?.containsKey('price') == true ? userData!['price'] : '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header and user details (unchanged)
                Container(
                  height: 300.0,
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
                                "Driver Dashboard",
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
                        // Name and phone info
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.green),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: name,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Brand-Bold",
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.red),
                            const SizedBox(width: 18.0),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Phone',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: phone,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontFamily: "Brand-Bold",
                                      color: AppColors.secondaryColor,
                                      fontWeight: FontWeight.bold,
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
                DashboardTile(
                  icon: Icons.verified,
                  title: 'Verification',
                  subtitle: 'Verify yourself',
                  onTap: () {
                    showBottomSheet(
                      context,
                      "Verification",
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // CNIC Number Field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'XXXXX-XXXXXXX-X',
                                labelText: 'Enter Cnic Number',
                                border: OutlineInputBorder(),
                                suffixIcon: cnicController.text.isEmpty
                                    ? Icon(Icons.error, color: Colors.red)
                                    : Icon(Icons.check, color: Colors.green),
                              ),
                              inputFormatters: [
                                MaskedInputFormatter(
                                    '#####-#######-#'), // CNIC format
                              ],
                              keyboardType: TextInputType.number,
                              controller: cnicController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your CNIC';
                                } else if (value.replaceAll('-', '').length !=
                                    13) {
                                  return 'Enter a valid CNIC (XXXXX-XXXXXXX-X)';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Driving License Number Field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'XXXXX',
                                labelText: 'Enter Driving License Number',
                                border: OutlineInputBorder(),
                                suffixIcon: licenseController.text.isEmpty
                                    ? Icon(Icons.error, color: Colors.red)
                                    : Icon(Icons.check, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                MaskedInputFormatter('#####'), // LICENSE format
                              ],
                              controller: licenseController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your license number';
                                } else if (value.length != 5) {
                                  return 'Enter a valid license number (XXXXX)';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                DashboardTile(
                  icon: Icons.directions_car,
                  title: 'Registration',
                  subtitle: 'Register your vehicle',
                  onTap: () {
                    showBottomSheet(
                      context,
                      "Vehicle Registration",
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Vehicle Number Field
                            TextFormField(
                              decoration: InputDecoration(
                                hintText: 'XXX-0000',
                                labelText: 'Vehicle Number',
                                border: OutlineInputBorder(),
                                suffixIcon: vehicleNumberController.text.isEmpty
                                    ? Icon(Icons.error, color: Colors.red)
                                    : Icon(Icons.check, color: Colors.green),
                              ),
                              inputFormatters: [
                                MaskedInputFormatter('###-0000'),
                              ],
                              controller: vehicleNumberController,
                              onChanged: (value) {
                                print(value); // Debugging the entered value
                              },
                            ),
                            const SizedBox(height: 10),

                            // Vehicle Model Field with Autocomplete
                            Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return vehicleModels.where((String option) {
                                  return option.contains(textEditingValue.text);
                                });
                              },
                              onSelected: (String selection) {
                                vehicleModelController.text = selection;
                                print('Selected Vehicle Model: $selection');
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Vehicle Model',
                                    hintText: 'XXXX',
                                    border: OutlineInputBorder(),
                                    suffixIcon: textEditingController
                                            .text.isEmpty
                                        ? Icon(Icons.error, color: Colors.red)
                                        : Icon(Icons.check,
                                            color: Colors.green),
                                  ),
                                  inputFormatters: [
                                    MaskedInputFormatter(
                                        '####'), // Vehicle model format
                                  ],
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your vehicle model';
                                    } else if (value.length != 4) {
                                      return 'Enter a valid vehicle model (XXXX)';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Vehicle Color Field
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Color',
                                border: OutlineInputBorder(),
                                suffixText: 'Select Color',
                                suffixStyle: TextStyle(
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              controller: vehicleColorController,
                              onTap: () async {
                                Color? pickedColor = await showDialog(
                                  context: context,
                                  builder: (context) {
                                    Color tempColor = Colors.white;
                                    return AlertDialog(
                                      title: const Text('Pick a color'),
                                      content: SingleChildScrollView(
                                        child: BlockPicker(
                                          pickerColor: tempColor,
                                          onColorChanged: (color) {
                                            tempColor = color;
                                          },
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Select'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(tempColor);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (pickedColor != null) {
                                  setState(() {
                                    vehicleColorController.text =
                                        ColorNames.guess(pickedColor);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your vehicle color';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),

                            // Vehicle Name Field with Autocomplete
                            Autocomplete<String>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<String>.empty();
                                }
                                return vehicleNames.where((String option) {
                                  return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (String selection) {
                                vehicleNameController.text = selection;
                                print('Selected Vehicle Name: $selection');
                              },
                              fieldViewBuilder: (BuildContext context,
                                  TextEditingController textEditingController,
                                  FocusNode focusNode,
                                  VoidCallback onFieldSubmitted) {
                                return TextFormField(
                                  controller: textEditingController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    labelText: 'Vehicle Name',
                                    border: OutlineInputBorder(),
                                    suffixIcon: textEditingController
                                            .text.isEmpty
                                        ? Icon(Icons.error, color: Colors.red)
                                        : Icon(Icons.check,
                                            color: Colors.green),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your vehicle name';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),

                            // Vehicle Seats Field
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Total seats',
                                border: OutlineInputBorder(),
                                hintText: '00',
                                suffixIcon: vehicleSeatcontroller.text.isEmpty
                                    ? Icon(Icons.error, color: Colors.red)
                                    : Icon(Icons.check, color: Colors.green),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                MaskedInputFormatter(
                                    '00'), // Total seats format
                              ],
                              controller: vehicleSeatcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the total number of seats';
                                } else if (value.length != 2) {
                                  return 'Enter a valid number of seats (00)';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                DashboardTile(
                  icon: Icons.location_on,
                  title: 'Routes',
                  subtitle: 'Add your route details',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20.0)),
                      ),
                      builder: (context) {
                        return StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return DraggableScrollableSheet(
                              expand: false,
                              initialChildSize: 0.8,
                              minChildSize: 0.5,
                              maxChildSize: 1.0,
                              builder: (context, scrollController) {
                                return SingleChildScrollView(
                                  controller: scrollController,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: 20.0,
                                      left: 16.0,
                                      right: 16.0,
                                      bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom +
                                          20.0,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          "Add Route Details",
                                          style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20.0),
                                        // Dynamically updating content
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Text(
                                              "Pickup Location",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextFormField(
                                              controller:
                                                  startLocationController,
                                              decoration: InputDecoration(
                                                labelText:
                                                    "Enter Pickup Location",
                                                suffixIcon:
                                                    startLocationController
                                                            .text.isEmpty
                                                        ? Icon(Icons.error,
                                                            color: Colors.red)
                                                        : Icon(Icons.check,
                                                            color:
                                                                Colors.green),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            //  const SizedBox(height: 10),
                                            TextField(
                                              controller:
                                                  startPickupTimeController,
                                              decoration: const InputDecoration(
                                                labelText: "Enter Pickup Time",
                                              ),
                                              readOnly: true,
                                              onTap: () async {
                                                TimeOfDay? pickedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                        colorScheme:
                                                            ColorScheme.light(
                                                          primary: AppColors
                                                              .primaryColor, // header background color
                                                          onPrimary: Colors
                                                              .white, // header text color
                                                          onSurface: AppColors
                                                              .secondaryColor, // body text color
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                AppColors
                                                                    .primaryColor, // button text color
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    startPickupTimeController
                                                            .text =
                                                        pickedTime
                                                            .format(context);
                                                  });
                                                }
                                              },
                                            ),

                                            const SizedBox(height: 16),
                                            const Text(
                                              "End Location",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextFormField(
                                              controller: endLocationController,
                                              decoration: InputDecoration(
                                                labelText: "Enter End Location",
                                                suffixIcon:
                                                    endLocationController
                                                            .text.isEmpty
                                                        ? Icon(
                                                            Icons.error,
                                                            color: Colors.red)
                                                        : Icon(Icons.check,
                                                            color:
                                                                Colors.green),
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            const SizedBox(height: 10),
                                            TextField(
                                              controller:
                                                  endPickupTimeController,
                                              decoration: const InputDecoration(
                                                labelText: "Enter dropoff Time",
                                              ),
                                              readOnly: true,
                                              onTap: () async {
                                                TimeOfDay? pickedTime =
                                                    await showTimePicker(
                                                  context: context,
                                                  initialTime: TimeOfDay.now(),
                                                  builder:
                                                      (BuildContext context,
                                                          Widget? child) {
                                                    return Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                        colorScheme:
                                                            ColorScheme.light(
                                                          primary: AppColors
                                                              .primaryColor, // header background color
                                                          onPrimary: Colors
                                                              .white, // header text color
                                                          onSurface: AppColors
                                                              .secondaryColor, // body text color
                                                        ),
                                                        textButtonTheme:
                                                            TextButtonThemeData(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                AppColors
                                                                    .primaryColor, // button text color
                                                          ),
                                                        ),
                                                      ),
                                                      child: child!,
                                                    );
                                                  },
                                                );
                                                if (pickedTime != null) {
                                                  setState(() {
                                                    endPickupTimeController
                                                            .text =
                                                        pickedTime
                                                            .format(context);
                                                  });
                                                }
                                              },
                                            ),
                                            const SizedBox(height: 10),
                                            TextField(
                                              controller: priceController,
                                              decoration: InputDecoration(
                                                labelText: "Price for trip",
                                                suffixIcon: priceController
                                                        .text.isEmpty
                                                    ? Icon(Icons.error,
                                                        color: Colors.red)
                                                    : Icon(Icons.check,
                                                        color: Colors.green),
                                              ),
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "Stops",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 8),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: stops.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  elevation: 4,
                                                  margin: const EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        TextField(
                                                          controller:
                                                              stops[index]
                                                                  ["name"],
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Stop ${index + 1} Name",
                                                            suffixIcon: stops[index]
                                                                            [
                                                                            "name"]
                                                                        ?.text
                                                                        .isEmpty ??
                                                                    true
                                                                ? Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red)
                                                                : Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .green),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        TextField(
                                                          controller: stops[
                                                                  index]
                                                              ["stop_price"],
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Stop ${index + 1} Price",
                                                            suffixIcon: stops[index]
                                                                            [
                                                                            "stop_price"]
                                                                        ?.text
                                                                        .isEmpty ??
                                                                    true
                                                                ? Icon(
                                                                    Icons.error,
                                                                    color: Colors
                                                                        .red)
                                                                : Icon(
                                                                    Icons.check,
                                                                    color: Colors
                                                                        .green),
                                                          ),
                                                        ),
                                                        TextField(
                                                          controller:
                                                              stops[index]
                                                                  ["time"],
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Stop ${index + 1} Time of Arrival",
                                                          ),
                                                          readOnly: true,
                                                          onTap: () async {
                                                            TimeOfDay?
                                                                pickedTime =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  TimeOfDay
                                                                      .now(),
                                                              builder: (BuildContext
                                                                      context,
                                                                  Widget?
                                                                      child) {
                                                                return Theme(
                                                                  data: Theme.of(
                                                                          context)
                                                                      .copyWith(
                                                                    colorScheme:
                                                                        ColorScheme
                                                                            .light(
                                                                      primary:
                                                                          AppColors
                                                                              .primaryColor, // header background color
                                                                      onPrimary:
                                                                          Colors
                                                                              .white, // header text color
                                                                      onSurface:
                                                                          AppColors
                                                                              .secondaryColor, // body text color
                                                                    ),
                                                                    textButtonTheme:
                                                                        TextButtonThemeData(
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        foregroundColor:
                                                                            AppColors.primaryColor, // button text color
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  child: child!,
                                                                );
                                                              },
                                                            );

                                                            if (pickedTime !=
                                                                null) {
                                                              final now =
                                                                  DateTime
                                                                      .now();
                                                              final selectedTime =
                                                                  DateTime(
                                                                now.year,
                                                                now.month,
                                                                now.day,
                                                                pickedTime.hour,
                                                                pickedTime
                                                                    .minute,
                                                              );

                                                              final formattedTime =
                                                                  DateFormat(
                                                                          'hh:mm a')
                                                                      .format(
                                                                          selectedTime); // Formatting to include AM/PM

                                                              setState(() {
                                                                stops[index][
                                                                            "time"]
                                                                        ?.text =
                                                                    formattedTime;
                                                              });
                                                            }
                                                          },
                                                        ),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons.delete,
                                                                color:
                                                                    Colors.red),
                                                            onPressed: () {
                                                              setState(() {
                                                                removeStop(
                                                                    index);
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  addStop();
                                                });
                                              },
                                              icon: const Icon(Icons.add,
                                                  color:
                                                      AppColors.secondaryColor),
                                              label: const Text("Add Stop"),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryColor,
                                                foregroundColor:
                                                    AppColors.secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.secondaryColor,
                                            padding: const EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            saveDriverProfile(
                                                context, "Routes");
                                            Navigator.pop(
                                                context); // Close the bottom sheet
                                          },
                                          child: const Text(
                                            "Submit",
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                DashboardTile(
                  icon: Icons.stop_outlined,
                  title: 'Stops List',
                  subtitle: 'View your stops list',
                  onTap: () {
                    showBottomSheet(
                      context,
                      "Stops List",
                      FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('driver_profile')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text("Error fetching stops data"));
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                                child: Text("No stops data found"));
                          }

                          var stopsData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          var stopsList =
                              stopsData['stops'] as List<dynamic>? ?? [];

                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: stopsList.length,
                            itemBuilder: (context, index) {
                              var stop =
                                  stopsList[index] as Map<String, dynamic>;
                              return Card(
                                color: AppColors.primaryColor,
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.stop_circle,
                                    color: AppColors.lightPrimary,
                                  ),
                                  contentPadding: const EdgeInsets.all(16.0),
                                  title: Text(
                                    "Stop Name: ${stop['stop_name']}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                        color: AppColors.secondaryColor),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8.0),
                                      Text(
                                        "Arrival Time: ${stop['arrival_time']}",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        "Price: ${stop['stop_price']}",
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(
                                    Icons.location_on,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                DashboardTile(
                  icon: Icons.event_seat,
                  title: 'Seats View',
                  subtitle: 'View available and booked seats',
                  onTap: () {
                    showBottomSheet(
                      context,
                      "Seats View",
                      FutureBuilder<DocumentSnapshot>(
                        future: _firestore
                            .collection('driver_profile')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text("Error fetching seats data"));
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Center(
                                child: Text("No seats data found"));
                          }

                          var seatsData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          var totalSeats = seatsData['vehicleSeat'] ?? 0;
                          var availableSeats =
                              seatsData['available_seats'] ?? 0;
                          var bookedSeats =
                              seatsData['booked_seats'] as List<dynamic>? ?? [];

                          return GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4, // Number of columns
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                            ),
                            itemCount: totalSeats,
                            itemBuilder: (context, index) {
                              bool isBooked = index < bookedSeats.length;
                              String seatImage;
                              Color? seatColor;
                              if (isBooked) {
                                String gender = bookedSeats[index];
                                seatImage = gender == 'female'
                                    ? 'assets/woman.png'
                                    : gender == 'male'
                                        ? 'assets/man.png'
                                        : 'assets/seat.png';
                                seatColor = gender == 'female'
                                    ? Colors.pink
                                    : gender == 'male'
                                        ? const Color.fromARGB(255, 0, 61, 110)
                                        : Colors.black; // Change
                              } else {
                                seatImage = 'assets/seat.png';
                              }
                              return Column(
                                children: [
                                  Image.asset(
                                    seatImage,
                                    color: seatColor,
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(
                                    'Seat ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
