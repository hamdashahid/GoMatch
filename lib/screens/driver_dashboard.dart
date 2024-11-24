import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/components/driver_dashboard_screen/dashboard_tile.dart';
import 'package:gomatch/utils/colors.dart';

class DriverDashboardScreen extends StatefulWidget {
  static const String idScreen = "DriverDashboardScreen";

  @override
  _DriverDashboardScreenState createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  TextEditingController cnicController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleModelController = TextEditingController();
  TextEditingController vehicleColorController = TextEditingController();
  TextEditingController vehicleNameController = TextEditingController();
  TextEditingController startLocationController = TextEditingController();
  TextEditingController endLocationController = TextEditingController();
  TextEditingController vehicleSeatcontroller = TextEditingController();
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
                      saveDriverProfile(context, title);

                      Navigator.pop(context); // Close the bottom sheet
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
          'vehicleSeat': vehicleSeatcontroller.text.trim(),
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
      stops.add({
        "name": TextEditingController(),
        "time": TextEditingController(),
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

    final routeData = {
      "start_location": startLocationController.text,
      "start_pickup_time": startPickupTimeController.text,
      "end_location": endLocationController.text,
      "end_pickup_time": endPickupTimeController.text,
      "price": priceController.text,
      "stops": stops.map((stop) {
        return {
          "stop_name": stop["name"]?.text,
          "arrival_time": stop["time"]?.text,
        };
      }).toList(),
      "timestamp": FieldValue.serverTimestamp(),
    };

    storeToFirestore(routeData);
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
              userData?.containsKey('total_seats') == true
                  ? userData!['total_seats']
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
                // Dashboard tiles with bottom sheets
                DashboardTile(
                  icon: Icons.verified,
                  title: 'Verification',
                  subtitle: 'Verify yourself',
                  onTap: () {
                    showBottomSheet(
                      context,
                      "Verification",
                      Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Cnic Number',
                              border: OutlineInputBorder(),
                            ),
                            controller: cnicController,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Enter Driving License Number',
                              border: OutlineInputBorder(),
                            ),
                            controller: licenseController,
                          ),
                        ],
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
                      Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Number',
                              border: OutlineInputBorder(),
                            ),
                            controller: vehicleNumberController,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Model',
                              border: OutlineInputBorder(),
                            ),
                            controller: vehicleModelController,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Color',
                              border: OutlineInputBorder(),
                            ),
                            controller: vehicleColorController,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Vehicle Name',
                              border: OutlineInputBorder(),
                            ),
                            controller: vehicleNameController,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Total seats',
                              border: OutlineInputBorder(),
                            ),
                            controller: vehicleSeatcontroller,
                          ),
                        ],
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
                                              "Start Location",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextFormField(
                                              controller:
                                                  startLocationController,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    "Enter Start Location",
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
                                            // TextFormField(
                                            //   controller:
                                            //       startPickupTimeController,
                                            //   decoration: const InputDecoration(
                                            //     labelText: "Enter Pickup Time",
                                            //   ),
                                            //   keyboardType:
                                            //       TextInputType.datetime,
                                            // ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              "End Location",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            TextFormField(
                                              controller: endLocationController,
                                              decoration: const InputDecoration(
                                                labelText: "Enter End Location",
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            // TextField(
                                            //   controller:
                                            //       endPickupTimeController,
                                            //   decoration: const InputDecoration(
                                            //     labelText: "Enter Pickup Time",
                                            //   ),
                                            //   keyboardType:
                                            //       TextInputType.datetime,
                                            // ),

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
                                              decoration: const InputDecoration(
                                                labelText: "Price for trip",
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
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 10),
                                                        TextField(
                                                          controller:
                                                              stops[index]
                                                                  ["time"],
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                "Stop ${index + 1} Time of Arrival",
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .datetime,
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
                              return ListTile(
                                title: Text("Stop Name: ${stop['stop_name']}"),
                                subtitle: Text(
                                    "Arrival Time: ${stop['arrival_time']}"),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                // Additional content...
              ],
            ),
          ),
        ),
      ),
    );
  }
}
