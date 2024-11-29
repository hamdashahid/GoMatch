import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class RideRequestScreen extends StatefulWidget {
  // final String driverId;
  static const idScreen = 'ride_request_screen';

  // RideRequestScreen({});

  @override
  _RideRequestScreenState createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String driverId;

  _RideRequestScreenState() : driverId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Requests"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('driver_profile')
            .doc(driverId)
            .collection('ride_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ride requests found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var rideRequest = snapshot.data!.docs[index];
              return Card(
                color: AppColors.primaryColor,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    'Pickup: ${rideRequest['pickupLocation']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.0),
                      Text('Destination: ${rideRequest['destination']}',
                          style: TextStyle(color: Colors.white)),
                      SizedBox(height: 8.0),
                      Text('Status: ${rideRequest['status']}',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  onTap: () {
                    _showRideRequestDetails(rideRequest);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showRideRequestDetails(DocumentSnapshot rideRequest) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          title: Text('Ride Request Details',
              style: TextStyle(color: AppColors.secondaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pickup Location: ${rideRequest['pickupLocation']}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Destination: ${rideRequest['destination']}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Status: ${rideRequest['status']}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Created At: ${rideRequest['createdAt'].toDate()}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateRideRequestStatus(rideRequest.id, 'accepted');
                Navigator.of(context).pop();
              },
              child: Text(
                'Accept',
                style: TextStyle(color: AppColors.secondaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                _updateRideRequestStatus(rideRequest.id, 'rejected');
                Navigator.of(context).pop();
              },
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateRideRequestStatus(String requestId, String status) {
    _firestore
        .collection('driver_profile')
        .doc(driverId)
        .collection('ride_requests')
        .doc(requestId)
        .update({'status': status});
  }
}
