import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:gomatch/screens/driver_reciept.dart';
import 'package:gomatch/utils/colors.dart';

class DriverPaymentsScreen extends StatefulWidget {
  static const String idScreen = 'DriverPaymentsScreen';

  @override
  _DriverPaymentsScreenState createState() => _DriverPaymentsScreenState();
}

class _DriverPaymentsScreenState extends State<DriverPaymentsScreen> {
  late String driverId;
  Map<String, String> passengerNames = {}; // Cache for passenger names
  bool isLoadingPassengers = false;

  @override
  void initState() {
    super.initState();
    driverId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (driverId.isNotEmpty) {
      _fetchPassengerNames();
    }
  }

  Future<void> _fetchPassengerNames() async {
    setState(() {
      isLoadingPassengers = true;
    });

    try {
      final rideRequests = await FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(driverId)
          .collection('ride_requests')
          .get();

      for (var ride in rideRequests.docs) {
        final passengerId = ride['passengerId'];
        if (!passengerNames.containsKey(passengerId)) {
          final passengerDoc = await FirebaseFirestore.instance
              .collection('passenger_profile')
              .doc(passengerId)
              .get();
          passengerNames[passengerId] =
              passengerDoc.exists ? passengerDoc['name'] : 'Unknown';
        }
      }
    } catch (e) {
      print('Error fetching passenger names: $e');
    }

    setState(() {
      isLoadingPassengers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: driverId.isEmpty || isLoadingPassengers
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('driver_profile')
                  .doc(driverId)
                  .collection('ride_requests')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No rides found.'));
                }

                final rides = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final rideId = 'Ride #${index + 1}';
                    final rawDate = ride['paymentDate'];
                    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(rawDate.toDate());
                    final amount = ride['paymentAmount'];
                    final passengerId = ride['passengerId'];
                    final passengerName =
                        passengerNames[passengerId] ?? 'Loading...';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: AppColors.selectedCardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.primaryColor,
                              ),
                              child: Text(
                                rideId,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: const Color.fromARGB(255, 255, 153, 0),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: AppColors.textColor),
                                SizedBox(width: 8),
                                Text(formattedDate,
                                    style:
                                        TextStyle(color: AppColors.textColor)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.person, color: AppColors.textColor),
                                SizedBox(width: 8),
                                Text('Passenger: $passengerName',
                                    style:
                                        TextStyle(color: AppColors.textColor)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.monetization_on,
                                    color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Amount: \$${double.parse(amount).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DriverReceiptScreen(
                                        receiptNumber: ride['receiptNumber'],
                                        date: formattedDate,
                                        amount: amount,
                                        paymentMethod: ride['paymentMethod'],
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryColor,
                                  foregroundColor: AppColors.primaryColor,
                                ),
                                child: Text('View Receipt'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
