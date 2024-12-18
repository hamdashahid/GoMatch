import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/screens/payment_screen.dart';
import 'package:gomatch/utils/colors.dart';

class AvailableSeatsScreen extends StatefulWidget {
  final String? driverUid;
  final String? price;
  final String? rideId;
  static const String idScreen = "AvailableSeats";

  AvailableSeatsScreen({super.key, this.driverUid, this.price, this.rideId});

  @override
  _AvailableSeatsState createState() => _AvailableSeatsState();
}

class _AvailableSeatsState extends State<AvailableSeatsScreen> {
  int totalSeats = 0;
  List<String> bookedSeats = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSideMenuClosed = true;
  int receiptNumber = 0;
  // String ride = "ride";
  @override
  void initState() {
    super.initState();
    fetchSeats();
  }

  Future<void> fetchSeats() async {
    try {
      // Fetch the driver's profile document

      DocumentSnapshot driverProfile = await FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(widget.driverUid)
          .get();

      if (driverProfile.exists) {
        // Safely access 'booked_seats' and 'total_seats' fields
        setState(() {
          FirebaseFirestore.instance
              .collection('driver_profile')
              .doc(widget.driverUid)
              .update({'available_seats': totalSeats - bookedSeats.length});
          totalSeats = driverProfile['vehicleSeat'] ?? 0;
          bookedSeats = (driverProfile['booked_seats'] as List<dynamic>)
              .map((e) => e.toString())
              .toList();
          print(totalSeats);
          print(bookedSeats);
        });
      } else {
        print("Driver profile does not exist.");
      }
    } catch (e) {
      print("Error fetching seats: $e");
    }
  }

  void bookSeat(int index) async {
    try {
      // Show gender selection dialog
      String? gender = await showDialog<String>(
        context: context,
        builder: (context) => GenderDialog(),
      );

      if (gender != null) {
        // Fetch the driver's profile
        DocumentSnapshot driverProfile = await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(widget.driverUid)
            .get();
        List<String> existingBookedSeats = [];
        if (driverProfile.exists) {
          existingBookedSeats = List<String>.from(
            (driverProfile.data() as Map<String, dynamic>)['booked_seats'] ??
                [],
          );
        }

        // Ensure the list is large enough
        while (existingBookedSeats.length <= index) {
          existingBookedSeats.add('');
        }

        // Update the seat at the specified index
        existingBookedSeats[index] = gender;

        // Update Firestore for driver profile
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(widget.driverUid)
            .set(
          {'booked_seats': existingBookedSeats},
          SetOptions(merge: true),
        );

        // Update Firestore for user profile
        await FirebaseFirestore.instance
            .collection('passenger_profile')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .set({
          'reserved_seat': index,
          'ride_id': widget.rideId,
        }, SetOptions(merge: true));

        // Update the local state
        setState(() {
          bookedSeats = existingBookedSeats;
        });

        print("Seat booked successfully!");
      }
    } catch (e) {
      print("Error booking seat: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Available Seats'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemCount: totalSeats,
        itemBuilder: (context, index) {
          String seatStatus =
              bookedSeats.length > index ? bookedSeats[index] : '';
          bool isUserSeat = seatStatus == FirebaseAuth.instance.currentUser!.uid;
          return GestureDetector(
            onTap: seatStatus.isEmpty && !bookedSeats.contains(FirebaseAuth.instance.currentUser!.uid)
                ? () => bookSeat(index)
                : isUserSeat
                    ? () => _showDeselectDialog(index)
                    : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    seatStatus.isEmpty
                        ? 'assets/seat.png'
                        : seatStatus == 'male'
                            ? 'assets/man.png'
                            : 'assets/woman.png',
                    color: seatStatus.isEmpty
                        ? Colors.grey
                        : seatStatus == 'male'
                            ? const Color.fromARGB(255, 0, 61, 110)
                            : Colors.pink,
                    width: 50.0,
                    height: 50.0,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Seat ${index + 1}',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    seatStatus.isEmpty ? 'Available' : isUserSeat ? 'Your Seat' : 'Reserved',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: seatStatus.isEmpty ? Colors.green : isUserSeat ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  price: widget.price!,
                  rideId: widget.rideId!,
                  driverId: widget.driverUid!,
                ),
              ));
        },
        child: Icon(Icons.done),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            fetchDriverAndShowBottomSheet(context, widget.driverUid!);
          },
          child: Text('Show Car Details'),
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            backgroundColor: AppColors.secondaryColor,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            textStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showDeselectDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deselect Seat'),
          content: Text('Are you sure you want to deselect this seat?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deselectSeat(index);
              },
              child: Text('Deselect'),
            ),
          ],
        );
      },
    );
  }

  void deselectSeat(int index) async {
    try {
      // Fetch the driver's profile
      DocumentSnapshot driverProfile = await FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(widget.driverUid)
          .get();
      List<String> existingBookedSeats = [];
      if (driverProfile.exists) {
        existingBookedSeats = List<String>.from(
          (driverProfile.data() as Map<String, dynamic>)['booked_seats'] ?? [],
        );
      }

      // Ensure the list is large enough
      while (existingBookedSeats.length <= index) {
        existingBookedSeats.add('');
      }

      // Update the seat at the specified index
      existingBookedSeats[index] = '';

      // Update Firestore for driver profile
      await FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(widget.driverUid)
          .set(
        {'booked_seats': existingBookedSeats},
        SetOptions(merge: true),
      );

      // Update Firestore for user profile
      await FirebaseFirestore.instance
          .collection('passenger_profile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'reserved_seat': FieldValue.delete(),
        'ride_id': FieldValue.delete(),
      }, SetOptions(merge: true));

      // Update the local state
      setState(() {
        bookedSeats = existingBookedSeats;
      });

      print("Seat deselected successfully!");
    } catch (e) {
      print("Error deselecting seat: $e");
    }
  }

  void fetchDriverAndShowBottomSheet(
      BuildContext context, String driverUid) async {
    try {
      // Fetch driver data from Firestore
      DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance
          .collection('driver_profile')
          .doc(driverUid)
          .get();

      if (driverSnapshot.exists) {
        Map<String, dynamic> driverData =
            driverSnapshot.data() as Map<String, dynamic>;
        // Show the bottom sheet with the fetched driver data
        _showCarpoolBottomSheet(context, driverData);
      } else {
        // Handle the case where the driver does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Driver data not found.')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching driver data: $e')),
      );
    }
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

  // Function to show the bottom sheet of Car Button
  void _showCarpoolBottomSheet(
      BuildContext context, Map<String, dynamic> driverData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context)
                    .pop(); // Close bottom sheet on outside tap
              },
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {}, // Prevent dismissing when tapping inside
                    child: DraggableScrollableSheet(
                      expand: true,
                      initialChildSize: 0.6,
                      minChildSize: 0.5,
                      maxChildSize: 1,
                      builder: (context, scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 50,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Driver Details",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.person,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(driverData['name'] ?? 'N/A'),
                                    subtitle:
                                        Text('Phone: ${driverData['phone']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.directions_car,
                                      color: AppColors.secondaryColor,
                                    ),
                                    title: Text(
                                      '${driverData['vehicleName']} - ${driverData['vehicleColor']}',
                                    ),
                                    subtitle: Text(
                                        'Model: ${driverData['vehicleModel']}'),
                                    trailing: Text(
                                        'Seats: ${driverData['available_seats']}/${driverData['total_seats']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.currency_exchange,
                                        color: AppColors.secondaryColor),
                                    title: const Text('Price'),
                                    subtitle:
                                        Text('PKR ${driverData['price']}'),
                                  ),
                                  const Divider(),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Route Details",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: AppColors.secondaryColor),
                                    title: Text(
                                        'From: ${driverData['start_location']['location']}'),
                                    subtitle: Text(
                                        'To: ${driverData['end_location']['location']}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.timer,
                                        color: AppColors.secondaryColor),
                                    title: Text(
                                        'Pickup Time: ${driverData['start_pickup_time']}'),
                                    subtitle: Text(
                                        'Drop-off Time: ${driverData['end_pickup_time']}'),
                                  ),
                                  const Divider(),
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      "Stops",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  ...List.generate(driverData['stops'].length,
                                      (index) {
                                    final stop = driverData['stops'][index];
                                    return ListTile(
                                      leading: const Icon(Icons.stop_circle,
                                          color: AppColors.secondaryColor),
                                      title: Text(
                                          stop['stop_name'] ?? 'Unknown Stop'),
                                      subtitle: Text(
                                          'Arrival Time: ${stop['arrival_time']}'),
                                    );
                                  }),
                                  const Divider(),
                                  // Center(
                                  //   child: ElevatedButton(
                                  //     style: ElevatedButton.styleFrom(
                                  //       backgroundColor:
                                  //           AppColors.secondaryColor,
                                  //       foregroundColor: AppColors.primaryColor,
                                  //     ),
                                  //     onPressed: () {
                                  //       Navigator.push(
                                  //         context,
                                  //         MaterialPageRoute(
                                  //           builder: (context) => PaymentScreen(
                                  //             price: driverData['price'],
                                  //           ),
                                  //         ),
                                  //       );
                                  //     },
                                  //     child: const Text('Confirm Booking'),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class GenderDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Gender'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'male'),
            child: Text('Male'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, 'female'),
            child: Text('Female'),
          ),
        ],
      ),
    );
  }
}
