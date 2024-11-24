// import 'package:flutter/material.dart';
// import 'ride_history_tile.dart';

// class RideHistoryList extends StatelessWidget {
//   const RideHistoryList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       children: const [
//         RideHistoryTile(
//           date: '20 Jun, 05:44 pm',
//           pickupLocation: 'Wah Model town Phase 1 Rd 9',
//           dropLocation: '17 Qabristan Road',
//           fare: 'Rs330.00',
//         ),
//         RideHistoryTile(
//           date: '8 Jun, 12:25 pm',
//           pickupLocation: 'A.K. Brohi Road 3',
//           dropLocation: 'Wah Model Town Phase 1 Extension',
//           fare: 'Rs0.00',
//           cancelled: true,
//         ),
//       ],
//     );
//   }
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/components/history_screen/driver_ride_history_tile.dart';

class RideHistoryList extends StatelessWidget {
  const RideHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User is not authenticated")),
      );
      return const Center(child: Text('User is not authenticated'));
    }
    String uid = user.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('passenger_profile/$uid/rides')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No ride history available'));
        }
        final rideDocs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: rideDocs.length,
          itemBuilder: (context, index) {
            final rideData = rideDocs[index].data() as Map<String, dynamic>;
            return RideHistoryTile(
              date: (rideData['timestamp'] as Timestamp).toDate().toString(),
              pickupLocation:
                  rideData['pickup_location'] ?? 'Unknown pickup location',
              dropLocation:
                  rideData['dropoff_location'] ?? 'Unknown drop location',
              fare: rideData['price'] ??
                  'Unknown fare', // Assuming fare is not available in the provided data structure
              cancelled:
                  false, // Assuming cancelled status is not available in the provided data structure
            );
          },
        );
      },
    );
  }
}
