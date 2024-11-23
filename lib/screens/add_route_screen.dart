import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/utils/colors.dart';

class AddRouteScreen extends StatefulWidget {
  static const String idScreen = "AddRouteScreen";
  AddRouteScreen({Key? key}) : super(key: key);
  @override
  _AddRouteScreenState createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController startPickupTimeController =
      TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController endPickupTimeController = TextEditingController();

  final List<Map<String, TextEditingController>> stops = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore.collection('driver_profile').add(data);
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
        endPickupTimeController.text.isEmpty) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Route Details"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Start Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: startLocationController,
                decoration: const InputDecoration(
                  labelText: "Enter Start Location",
                ),
              ),
              TextField(
                controller: startPickupTimeController,
                decoration: const InputDecoration(
                  labelText: "Enter Pickup Time",
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              const Text(
                "End Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: endLocationController,
                decoration: const InputDecoration(
                  labelText: "Enter End Location",
                ),
              ),
              TextField(
                controller: endPickupTimeController,
                decoration: const InputDecoration(
                  labelText: "Enter Pickup Time",
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              const Text(
                "Stops",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: stops[index]["name"],
                            decoration: InputDecoration(
                              labelText: "Stop ${index + 1} Name",
                            ),
                          ),
                          TextField(
                            controller: stops[index]["time"],
                            decoration: InputDecoration(
                              labelText: "Stop ${index + 1} Time of Arrival",
                            ),
                            keyboardType: TextInputType.datetime,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                removeStop(index);
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
                onPressed: addStop,
                icon: const Icon(Icons.add),
                label: const Text("Add Stop"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: handleSubmit,
                child: const Text("Submit"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
