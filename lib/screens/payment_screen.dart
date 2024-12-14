import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you have Firestore dependencies
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/providers/receipt.dart';
import 'package:gomatch/utils/colors.dart';

class PaymentScreen extends StatefulWidget {
  static const String idScreen = "PaymentScreen";
  final String price;
  final String? driverId;
  final String? rideId;
  PaymentScreen({super.key, required this.price, this.driverId, this.rideId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isSideMenuClosed = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Show payment options
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
          actions: <Widget>[
            TextButton(
              child: const Text('JazzCash'),
              onPressed: () {
                // _storeReceiptDetails('JazzCash');
                // Navigator.of(context).pop();
                _processPayment('JazzCash');
              },
            ),
            TextButton(
              child: const Text('EasyPaisa'),
              onPressed: () {
                // Navigator.of(context).pop();
                _processPayment('EasyPaisa');
              },
            ),
          ],
        );
      },
    );
  }

  // Handle payment processing
  void _processPayment(String paymentMethod) async {
    // Simulate a successful payment process
    await _storeReceiptDetails(paymentMethod);
    if (!mounted) return; // Ensure the widget is still mounted

    print('Payment successful');
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
          content: Text(
            'Your payment through $paymentMethod was successful. Your ride has been confirmed.',
            style: const TextStyle(
              fontFamily: "Brand-Regular",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Show Receipt',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () async {
                Navigator.of(context).pop();
                // final ride =
                //     await _firestore.collection('receipt').doc("1234").get();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReceiptScreen(
                    date: (DateTime.now()).toString(),
                    // receiptNumber: 1234,
                    amount: widget.price,
                    paymentMethod: paymentMethod,
                  ),
                ));
              },
            ),
            TextButton(
              child: const Text('OK',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                // Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Store receipt details in Firestore
  Future<void> _storeReceiptDetails(String paymentMethod) async {
    print('PRICE : ${widget.price}');
    if (widget.rideId != null && widget.driverId != null) {
      try {
        final ride = await _firestore.collection('receipt').doc('1234').get();
        // Store receipt details in ride_requests
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(widget.driverId)
            .collection('ride_requests')
            .doc(widget.rideId)
            .update({
          'paymentStatus': 'Completed',
          'paymentAmount': widget.price,
          'paymentMethod': paymentMethod,
          'paymentDate': DateTime.now(),
          'receiptNumber': ride['number'],
        });
        print('Receipt details stored successfully');
      } catch (e) {
        print("Error storing receipt details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(isMenuOpen: !isSideMenuClosed),
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text('Payment Screen'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      key: _scaffoldKey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                const Image(
                  image: AssetImage("assets/images/logoTransparent.png"),
                  width: 390.0,
                  height: 250.0,
                  alignment: Alignment.center,
                ),
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
                        const SizedBox(height: 5.0),
                        Stack(
                          children: [
                            const Center(
                              child: Text(
                                "Thank you for choosing GoMatch!",
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
                        const SizedBox(height: 10.0),
                        Text(
                          "Payment: Rs. ${widget.price}",
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
                          labelText: 'Phone Number',
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
