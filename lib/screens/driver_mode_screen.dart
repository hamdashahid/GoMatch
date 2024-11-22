import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gomatch/screens/driver_dashboard.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DriverModeScreen extends StatefulWidget {
  static const String idScreen = "DriverModeScreen";

  const DriverModeScreen({super.key});

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
      body: driverRegistration(),
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

              uploadDocument('ID Card');
            },
            child: Text('Upload ID Card'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
              uploadDocument('Driver’s License');
            },
            child: Text('Upload Driver’s License'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
              uploadDocument('Profile Photo');
            },
            child: Text('Upload Profile Photo'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement document upload functionality here
              uploadDocument('Vehicle Registration');
            },
            child: Text('Upload Additional Documents'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implement KYC verification functionality here
              setState(() {
                isVerified = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              });
            },
            child: Text('Submit for Verification'),
          ),
        ],
      ),
    );
  }

  Future<void> uploadDocument(String documentType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName =
          '${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        // Upload file to Firebase Storage
        await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);
        String downloadURL = await FirebaseStorage.instance
            .ref('uploads/$fileName')
            .getDownloadURL();

        // Save file info to Firestore
        await FirebaseFirestore.instance.collection('driver_documents').add({
          'documentType': documentType,
          'url': downloadURL,
          'uploadedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$documentType uploaded successfully')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload $documentType')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No file selected')));
    }
  }

  void driverDashboard() {
    // return Padding(
    //   padding: const EdgeInsets.all(16.0),
    //   child: SingleChildScrollView(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.stretch,
    //       children: [
    //         Text('Driver Dashboard'),
    //         SizedBox(height: 20),
    //         Text('Available Routes:'),
    //         // Implement list of available routes here
    //         ListView(
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //           children: [
    //             ListTile(
    //               title: Text('Route 1'),
    //               subtitle: Text('From A to B'),
    //               onTap: () {
    //                 // Implement route selection functionality here
    //               },
    //             ),
    //             ListTile(
    //               title: Text('Route 2'),
    //               subtitle: Text('From C to D'),
    //               onTap: () {
    //                 // Implement route selection functionality here
    //               },
    //             ),
    //             ListTile(
    //               title: Text('Route 3'),
    //               subtitle: Text('From E to F'),
    //               onTap: () {
    //                 // Implement route selection functionality here
    //               },
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 20),
    //         Text('Pickup Locations:'),
    //         // Implement list of pickup locations here
    //         ListView(
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //           children: [
    //             ListTile(
    //               title: Text('Location 1'),
    //               subtitle: Text('123 Main St'),
    //             ),
    //             ListTile(
    //               title: Text('Location 2'),
    //               subtitle: Text('456 Elm St'),
    //             ),
    //             ListTile(
    //               title: Text('Location 3'),
    //               subtitle: Text('789 Oak St'),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 20),
    //         Text('Real-time Demand:'),
    //         // Implement real-time demand information here
    //         ListView(
    //           shrinkWrap: true,
    //           physics: NeverScrollableScrollPhysics(),
    //           children: [
    //             ListTile(
    //               title: Text('High demand in Area 1'),
    //               subtitle: Text('10 requests in the last hour'),
    //             ),
    //             ListTile(
    //               title: Text('Moderate demand in Area 2'),
    //               subtitle: Text('5 requests in the last hour'),
    //             ),
    //             ListTile(
    //               title: Text('Low demand in Area 3'),
    //               subtitle: Text('2 requests in the last hour'),
    //             ),
    //           ],
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () {
    //             // Implement route acceptance functionality here
    //             // to payment
    //           },
    //           child: Text('Accept Route'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
