import 'package:flutter/material.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/providers/receipt.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentScreen extends StatefulWidget {
  static const String idScreen = "PaymentScreen";
  final String price;
  PaymentScreen({super.key, required this.price});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isSideMenuClosed = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int receiptNumber = 0;

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

  void _processJazzCashPayment() async {
    // Implement JazzCash payment logic here
    fetchData();
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
            'Your payment through JazzCash was successful. & your ride has been confirmed.',
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
            TextButton(
              child: const Text('Show Receipt',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(
                        receiptNumber: receiptNumber,
                        date: "12/12/2021",
                        amount: widget.price,
                        paymentMethod: "JazzCash"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _processEasyPaisaPayment() {
    // Implement EasyPaisa payment logic here
    fetchData();
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
            'Your payment through EasyPaisa was successful. & Your ride has been confirmed.',
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
            TextButton(
              child: const Text('Show Receipt',
                  style: TextStyle(color: AppColors.primaryColor)),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReceiptScreen(
                        receiptNumber: receiptNumber,
                        date: "12/12/2021",
                        amount: widget.price,
                        paymentMethod: "EasyPaisa"),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void fetchData() async {
    // Fetch data from Firestore
    DocumentSnapshot receipt = await FirebaseFirestore.instance
        .collection('receipt')
        .doc('1234')
        .get();

    if (receipt.exists) {
      // Process the receipt data
      // int currentReceiptNumber = int.parse(receipt['number']);
      receiptNumber = receipt['number'];
      // Update the receipt number in Firestore
      await FirebaseFirestore.instance
          .collection('receipt')
          .doc('1234')
          .update({'number': (receiptNumber + 1)});
      debugPrint('Receipt Data: ${receipt.data()}');
    } else {
      debugPrint('No such document!');
    }

    if (!mounted) return;
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
                                "Thankyou for choosing GoMatch!",
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
                          "Payment : \$${widget.price}",
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
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: TextField(
                      //         decoration: InputDecoration(
                      //           labelText: 'Expiry Date',
                      //           border: OutlineInputBorder(),
                      //           prefixIcon: Icon(Icons.date_range),
                      //           labelStyle:
                      //               TextStyle(color: AppColors.primaryColor),
                      //           enabledBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(
                      //                 color: AppColors.secondaryColor),
                      //           ),
                      //           focusedBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(
                      //                 color: AppColors.secondaryColor),
                      //           ),
                      //         ),
                      //         keyboardType: TextInputType.datetime,
                      //       ),
                      //     ),
                      //     const SizedBox(width: 10.0),
                      //     Expanded(
                      //       child: TextField(
                      //         decoration: InputDecoration(
                      //           labelText: 'CVV',
                      //           border: OutlineInputBorder(),
                      //           prefixIcon: Icon(Icons.lock),
                      //           labelStyle:
                      //               TextStyle(color: AppColors.primaryColor),
                      //           enabledBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(
                      //                 color: AppColors.secondaryColor),
                      //           ),
                      //           focusedBorder: OutlineInputBorder(
                      //             borderSide: BorderSide(
                      //                 color: AppColors.secondaryColor),
                      //           ),
                      //         ),
                      //         keyboardType: TextInputType.number,
                      //         obscureText: true,
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
