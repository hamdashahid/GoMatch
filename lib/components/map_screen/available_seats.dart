import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/utils/colors.dart';

class AvailableSeatsScreen extends StatefulWidget {
  final String? driverUid;
  static const String idScreen = "AvailableSeats";

  AvailableSeatsScreen({super.key, this.driverUid});

  @override
  _AvailableSeatsState createState() => _AvailableSeatsState();
}

class _AvailableSeatsState extends State<AvailableSeatsScreen> {
  int totalSeats = 0;
  List<String> bookedSeats = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSideMenuClosed = true;

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
          totalSeats = driverProfile['total_seats'] ??
              0; // Default to 0 seats if not available
          bookedSeats = List<String>.from(
              (driverProfile.data() as Map<String, dynamic>)['booked_seats'] ??
                  []); // Default to empty list if not available
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
        // Fetch the driver's profile to check if 'booked_seats' exists
        DocumentSnapshot driverProfile = await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(widget.driverUid)
            .get();
        driverProfile.reference
            .update({'available_seats': totalSeats - bookedSeats.length});
        // driverProfile.data()['available_seats'] = totalSeats - bookedSeats.length;
        List<String> existingBookedSeats = [];
        if (driverProfile.exists) {
          // Safely access 'booked_seats' field
          existingBookedSeats = List<String>.from(
              (driverProfile.data() as Map<String, dynamic>)['booked_seats'] ??
                  []);
        }

        // Ensure the 'booked_seats' list is large enough to accommodate the index
        while (existingBookedSeats.length <= index) {
          existingBookedSeats
              .add(''); // Fill with empty strings if the index is out of bounds
        }

        // Update the seat at the specified index
        existingBookedSeats[index] = gender;

        // Update or create the 'booked_seats' field in Firestore
        await FirebaseFirestore.instance
            .collection('driver_profile')
            .doc(widget.driverUid)
            .set(
                {'booked_seats': existingBookedSeats}, SetOptions(merge: true));

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
      // drawer: SideMenu(isMenuOpen: !isSideMenuClosed),
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
          return GestureDetector(
            onTap: seatStatus.isEmpty ? () => bookSeat(index) : null,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryColor, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
              // padding: EdgeInsets.all(8.0),
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
                    seatStatus.isEmpty ? 'Available' : 'Booked',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: seatStatus.isEmpty ? Colors.green : Colors.red,
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
          // Handle the done button press
          // Navigator.pop(context);
          Navigator.pushNamed(context, 'PaymentScreen');
        },
        child: Icon(Icons.done),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
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
