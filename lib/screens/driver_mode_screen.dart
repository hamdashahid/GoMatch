import 'package:flutter/material.dart';

class DriverModeScreen extends StatefulWidget {
  static const String idScreen = "DriverModeScreen";

  @override
  _DriverModeScreenState createState() => _DriverModeScreenState();
}

class _DriverModeScreenState extends State<DriverModeScreen> {
  bool isVerified = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Mode'),
      ),
      body: isVerified ? driverDashboard() : driverRegistration(),
    );
  }

  Widget driverRegistration() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Upload your documents to register as a driver'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
            },
            child: Text('Upload ID Card'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
            },
            child: Text('Upload Driver’s License'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
            },
            child: Text('Upload Profile Photo'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
            },
            child: Text('Upload Additional Documents'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement KYC verification functionality here
              setState(() {
                isVerified = true;
              });
            },
            child: Text('Submit for Verification'),
          ),
        ],
      ),
    );
  }

  Widget driverDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Driver Dashboard'),
          SizedBox(height: 20),
          Text('Available Routes:'),
          // Implement list of available routes here
          SizedBox(height: 20),
          Text('Pickup Locations:'),
          // Implement list of pickup locations here
          SizedBox(height: 20),
          Text('Real-time Demand:'),
          // Implement real-time demand information here
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement route acceptance functionality here
            },
            child: Text('Accept Route'),
          ),
        ],
      ),
    );
  }
}