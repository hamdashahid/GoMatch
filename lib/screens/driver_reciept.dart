import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/utils/colors.dart';

class DriverReceiptScreen extends StatelessWidget {
  final int receiptNumber;
  final String date;
  final String amount;
  final String paymentMethod;

  DriverReceiptScreen({
    required this.receiptNumber,
    required this.date,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
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
                    // Logo Container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/logoTransparent.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Title
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
                    // Details
                    buildReceiptDetail(Icons.receipt_long, 'Receipt Number',
                        receiptNumber.toString()),
                    buildReceiptDetail(Icons.date_range, 'Date', date),
                    buildReceiptDetail(Icons.attach_money, 'Amount', amount),
                    buildReceiptDetail(
                        Icons.payment, 'Payment Method', paymentMethod),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigator.pop(context);
                Navigator.pushNamed(context, 'SearchScreen');
              },
              icon: Icon(Icons.home, color: AppColors.primaryColor),
              label: Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building receipt details
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

// Dummy AppColors class for illustration (Replace with your actual implementation)
