import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/models/menu_btn.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:gomatch/configMaps.dart';
import 'package:flutter_osm_interface/flutter_osm_interface.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "HomeScreen";

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController homeaddressController =
      TextEditingController(text: 'Enter home address');
  TextEditingController workaddressController =
      TextEditingController(text: 'Enter work address');

  late google_maps.LatLng _pGooglePlex =
      google_maps.LatLng(0.0, 0.0); //user location
  static const google_maps.LatLng _kGooglePlex =
      google_maps.LatLng(37.4220, -122.0841); // Googleplex coordinates

  double currentLat = 37.4220; // Example latitude, replace with actual value
  double currentLng = -122.0841; // Example longitude, replace with actual value

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSideMenuClosed = true;
  int? selectedCarIndex; // Track which car is selected
  String currAddress = '';
  String homeAddress = '';
  String workAddress = '';

  String destinationAddress = '';

  double previousLatitude = 0.0;
  double previousLongitude = 0.0;

  int selectedRouteIndex = 0;

  // Define markers
  Set<google_maps.Marker> markers = {};
  GeoPoint pickupLocation =
      GeoPoint(latitude: 37.7749, longitude: -122.4194); // Example
  GeoPoint destinationLocation =
      GeoPoint(latitude: 37.4220, longitude: -122.0841); // Example

  // Variables to track button position
  double buttonX = 295; // Initial horizontal position
  double buttonY = 600; // Initial vertical position
  // late MapboxMapController newGoogleMapController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(isMenuOpen: !isSideMenuClosed),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      key: _scaffoldKey,
      body: Stack(
        children: [
          // const SizedBox(height: 20.0),

          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Welcome Banner
                Container(
                  // padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Image(
                        image: AssetImage("assets/images/logoTransparent.png"),
                        width: 390.0,
                        height: 250.0,
                        alignment: Alignment.center,
                      ),
                      // const SizedBox(height: 180),
                      const Text(
                        'Welcome to Go Match!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'You can enjoy a seamless and comfortable ride experience with our trusted drivers.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Features Section
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Why Ride with GoMatch?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _featureTile(
                        icon: Icons.directions_car_rounded,
                        title: 'Convenient Rides',
                        description:
                            'Get a ride quickly and easily with our user-friendly app.',
                      ),
                      const SizedBox(height: 15),
                      _featureTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Affordable Prices',
                        description:
                            'Enjoy competitive pricing and transparent fares.',
                      ),
                      const SizedBox(height: 15),
                      _featureTile(
                        icon: Icons.security_rounded,
                        title: 'Safety First',
                        description:
                            'We prioritize safety for both drivers and passengers.',
                      ),
                    ],
                  ),
                ),

                // Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the next screen or perform an action
                      // _showCarpoolBottomSheet(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            initialDropOffLocation: 'Set Dropoff',
                            homeAddress: homeaddressController.text,
                            workAddress: workaddressController.text,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      backgroundColor: AppColors.secondaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 40),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: AppColors.lightPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Function to show the bottom sheet of Car Button
  void _showCarpoolBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
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
                      initialChildSize: 0.5,
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

                                  // Add Home and Add Work options
                                  ListTile(
                                    leading: const Icon(Icons.home),
                                    title: const Text('Home Address'),
                                    subtitle:
                                        homeaddressController.text.isNotEmpty
                                            ? Text(homeaddressController.text)
                                            : const Text('Your home address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'home');
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.work),
                                    title: const Text('Work Address'),
                                    subtitle:
                                        workaddressController.text.isNotEmpty
                                            ? Text(workaddressController.text)
                                            : const Text('Your work address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'work');
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on,
                                        color: AppColors.secondaryColor),
                                    title: const Text('Set Pickup and Dropoff'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            initialDropOffLocation:
                                                'Set Dropoff',
                                            homeAddress:
                                                homeaddressController.text,
                                            workAddress:
                                                workaddressController.text,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
  // Button to set pickup and dropoff locations

  void _showAddressOptionsDialog(BuildContext context, String addressType) {
    String address = addressType == 'home' ? 'Home Address' : 'Work Address';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$address Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Navigate to the search screen and set this address as drop-off location
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(
                        initialDropOffLocation: addressType == 'home'
                            ? homeaddressController.text
                            : workaddressController.text,
                        homeAddress: homeaddressController.text,
                        workAddress: workaddressController.text,
                        // homeaddressController.text, // Pass the address to search screen
                        // initialPickupLocation: ,
                      ),
                    ),
                  );
                },
                child: const Text('Set Drop-Off Location'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the search screen and set this address as drop-off location
                  Navigator.pop(context); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreen(
                        initialDropOffLocation: addressType == 'home'
                            ? homeaddressController.text
                            : workaddressController.text,
                        homeAddress: homeaddressController.text,
                        workAddress: workaddressController.text,
                        // homeaddressController.text, // Pass the address to search screen
                        // initialPickupLocation: ,
                      ),
                    ),
                  );
                },
                child: const Text('Set Pickup Location'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle the logic to change the address
                  Navigator.pop(context); // Close the dialog
                  // Implement address change logic here (e.g., show another dialog for input)
                  _showChangeAddressDialog(context, addressType);
                },
                child: Text('Change $address'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChangeAddressDialog(BuildContext context, String addressType) {
    TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Change ${addressType == 'home' ? 'Home' : 'Work'} Address'),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(
              hintText:
                  'Enter new ${addressType == 'home' ? 'home' : 'work'} address',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update the address state here (you might need to handle this with a state management solution)
                setState(() {
                  if (addressType == 'home') {
                    // Save the new home address (e.g., to a variable or to persistent storage)
                    homeaddressController.text = addressController.text;
                  } else {
                    // Save the new work address
                    workaddressController.text = addressController.text;
                  }
                });

                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void navigateToMapPage(BuildContext context, double currentLat,
      double currentLng, double destLat, double destLng) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          pickupLocation: GeoPoint(latitude: currentLat, longitude: currentLng),
          destinationLocation: GeoPoint(latitude: destLat, longitude: destLng),
        ),
      ),
    );
  }
}
