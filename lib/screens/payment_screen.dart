import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class PaymentScreen extends StatefulWidget {
  static const String idScreen = "PaymentScreen";

  const PaymentScreen({super.key});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  void _showPaymentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Select Payment Method',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Brand-Bold",
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('JazzCash'),
                onTap: () {
                  Navigator.of(context).pop();
                  _processJazzCashPayment();
                },
              ),
              ListTile(
                title: const Text('EasyPaisa'),
                onTap: () {
                  Navigator.of(context).pop();
                  _processEasyPaisaPayment();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _processJazzCashPayment() {
    // Implement JazzCash payment logic here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Payment Successful',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Brand-Bold",
            ),
          ),
          content: const Text(
            'Your payment through JazzCash was successful.',
            style: TextStyle(
              fontFamily: "Brand-Regular",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _processEasyPaisaPayment() {
    // Implement EasyPaisa payment logic here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Payment Successful',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: "Brand-Bold",
            ),
          ),
          content: const Text(
            'Your payment through EasyPaisa was successful.',
            style: TextStyle(
              fontFamily: "Brand-Regular",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                // Header Section
                Container(
                  height: 150.0,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 241, 166, 53),
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
                                "Payment Screen",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontFamily: "Brand-Bold",
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        const Text(
                          "Securely complete your payment",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Brand-Regular",
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Payment Form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Enter Payment Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.credit_card),
                          labelStyle: TextStyle(color: AppColors.primaryColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.secondaryColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.secondaryColor),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Expiry Date',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.date_range),
                                labelStyle:
                                    TextStyle(color: AppColors.primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.secondaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.secondaryColor),
                                ),
                              ),
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                labelStyle:
                                    TextStyle(color: AppColors.primaryColor),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.secondaryColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppColors.secondaryColor),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          backgroundColor: AppColors.secondaryColor,
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          _showPaymentOptions(context);
                        },
                        child: const Text(
                          'Pay Now',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Brand-Bold",
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
