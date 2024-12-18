import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/utils/colors.dart';

class ReceiptScreen extends StatelessWidget {
  final String date;
  final String amount;
  final String paymentMethod;
  static const String idScreen = 'ReceiptScreen';

  ReceiptScreen({
    required this.date,
    required this.amount,
    required this.paymentMethod,
  });
  int receipt = 0;

  Future<void> fetchAndIncrementReceiptNumber() async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('receipt').doc('1234');
      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        receipt = documentSnapshot['number'];
        await documentReference.update({'number': receipt + 1});
      } else {
        throw Exception("Receipt not found");
      }
    } catch (e) {
      throw Exception("Error fetching and updating receipt number: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchAndIncrementReceiptNumber(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Payment Receipt"),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Payment Receipt"),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text("Payment Receipt"),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  Card(
                    color: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/logoTransparent.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Payment Receipt',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          SizedBox(height: 20),
                          Divider(),
                          buildReceiptDetail(Icons.receipt_long,
                              'Receipt Number', receipt.toString()),
                          buildReceiptDetail(Icons.date_range, 'Date & Time', date),
                          buildReceiptDetail(
                                  Icons.money_sharp, 'Amount Rs.', amount),
                          buildReceiptDetail(
                              Icons.payment, 'Payment Method', paymentMethod),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget buildReceiptDetail(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.lightPrimary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.secondaryColor,
        ),
      ),
    );
  }
}
