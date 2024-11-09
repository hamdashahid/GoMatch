import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gomatch/Assistants/assistantMethods.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/models/menu_btn.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:gomatch/components/home_screen/car_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gomatch/configMaps.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "HomeScreen";

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSideMenuClosed = true;
  int? selectedCarIndex; // Track which car is selected
  String currAddress = '';
  String homeAddress = '';
  String workAddress = '';

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  //For getting user's current location
  late Position currentPosition;

  // Variables to track user's previous location (for distance threshold)
  double previousLatitude = 0.0;
  double previousLongitude = 0.0;

  // Function to check and request location permissions
  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return; // Exit or show an error message
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied');
      return; // Exit or show an error message
    }

    locatePosition(); // Call your location function if permissions are granted
  }

  // Function to locate user's current position and handle geocoding
  void locatePosition() async {
    await _checkLocationPermission(); // Ensure permissions are checked first

    try {
      Position position = await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.high,
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Only geocode if moved more than 100 meters from the previous position
      double distance = Geolocator.distanceBetween(previousLatitude,
          previousLongitude, position.latitude, position.longitude);
      if (distance > 100) {
        // Check if the address is already cached
        String? cachedAddress =
            await AssistantMethods.getCachedAddress(position);
        if (cachedAddress != null) {
          setState(() {
            currentPosition = position;
            currAddress = cachedAddress;
          });
          return;
        }

        // Geocode the position if not cached
        String fetchedAddress =
            await AssistantMethods.searchCoordinateAddress(position, context);
        AssistantMethods.cacheAddress(
            position, fetchedAddress); // Cache the result

        setState(() {
          currentPosition = position;
          currAddress = fetchedAddress;
        });

        // Update previous location after geocoding
        previousLatitude = position.latitude;
        previousLongitude = position.longitude;
      }
    } catch (e) {
      print(e); // Handle error, e.g., permission denied
    }
  }

  static const LatLng _pGooglePlex = LatLng(37.42796133580664, -122.085749655962);

  // Variables to track button position
  double buttonX = 295; // Initial horizontal position
  double buttonY = 600; // Initial vertical position

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          mapKey.isNotEmpty
              ?  Padding(
                padding: const EdgeInsets.only(top: 90 , bottom: 160 , left: 20 , right: 20),
                child: GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: const CameraPosition(
                      target: _pGooglePlex,
                      zoom: 13,
                    ),
                    //for user's current loc
                    myLocationEnabled: true,
                      zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                
                    onMapCreated: (GoogleMapController controller) {
                      _controllerGoogleMap.complete(controller);
                      newGoogleMapController = controller;
                
                      //for user's current loc
                      locatePosition();
                    },
                  ),
              )
              : const Center(
                  child: Text('Google Maps is disabled'),
                ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 288,
            left: isSideMenuClosed ? -288 : 0,
            height: MediaQuery.of(context).size.height,
            child: SideMenu(isMenuOpen: !isSideMenuClosed),
          ),

          Positioned(
            top: 10,
            left: isSideMenuClosed ? 16 : 225,
            child: MenuBtn(
              press: () {
                setState(() {
                  isSideMenuClosed = !isSideMenuClosed;
                });
              },
              isMenuOpen: !isSideMenuClosed,
            ),
          ),

          // Draggable Floating Action Button
          Positioned(
            left: buttonX,
            top: buttonY,
            child: Draggable(
              feedback: Material(
                child: FloatingActionButton(
                  onPressed: () => _showCarpoolBottomSheet(context),
                  backgroundColor: AppColors.primaryColor,
                  child: const Icon(Icons.directions_car,
                      color: AppColors.secondaryColor),
                ),
              ),
              childWhenDragging: Container(), // Show nothing while dragging
              child: FloatingActionButton(
                onPressed: () => _showCarpoolBottomSheet(context),
                backgroundColor: AppColors.primaryColor,
                child: const Icon(Icons.directions_car,
                    color: AppColors.secondaryColor),
              ),
              onDragEnd: (details) {
                // Update the position of the button when drag ends
                setState(() {
                  buttonX =
                      details.offset.dx - 28; // Adjust to center the button
                  buttonY =
                      details.offset.dy - 28; // Adjust to center the button
                });
              },
            ),
          ),
        ],
      ),
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
            bool showCarDetails = false; // Toggler for switching views

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

                                  // Initial View: Search bar and Add Home/Work options
                                  GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        // Toggle to show car details
                                        showCarDetails = true;
                                      });
                                    },
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12.0,
                                          horizontal: 16.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.search),
                                            SizedBox(width: 8),
                                            Text(
                                              'Search Drop Off',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Add Home and Add Work options
                                  ListTile(
                                    leading: const Icon(Icons.home),
                                    title: const Text('Home Address'),
                                    subtitle: Text(homeAddress.isNotEmpty
                                        ? homeAddress
                                        : 'Your living home address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'home');
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.work),
                                    title: const Text('Work Address'),
                                    subtitle: Text(workAddress.isNotEmpty
                                        ? workAddress
                                        : 'Your office address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'work');
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
                        initialDropOffLocation:
                            address, // Pass the address to search screen
                      ),
                    ),
                  );
                },
                child: const Text('Set Drop-Off Location'),
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
                    homeAddress = addressController.text;
                  } else {
                    // Save the new work address
                    workAddress = addressController.text;
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
}
