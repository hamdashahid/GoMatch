import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
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
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  static const String idScreen = "HomeScreen";

  HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late LatLng _homeCoordinates;
  late LatLng _workCoordinates;

  // Function to add home and work markers to the map
  void _addHomeAndWorkMarkers() async {
    setState(() async {
      markers.add(
        Marker(
          markerId: const MarkerId('homeLocation'),
          position: _homeCoordinates,
          infoWindow: InfoWindow(title: 'Home Location'),
          // icon: await BitmapDescriptor.asset(
          //   const ImageConfiguration(size: Size(48, 48)),
          //   'assets/home_marker.png',
          // ),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('workLocation'),
          position: _workCoordinates,
          infoWindow: InfoWindow(title: 'Work Location'),
          // icon: await BitmapDescriptor.asset(
          //   const ImageConfiguration(size: Size(48, 48)),
          //   'assets/work_marker.png',
          // ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize addresses
    homeAddress = '123 Home St, Hometown';
    workAddress = '456 Work Ave, Worktown';
    _setInitialLocation();
    _initializeHomeAndWorkCoordinates();
  }

  Future<void> _initializeHomeAndWorkCoordinates() async {
    LatLng? homeCoords = await _geocodeAddress(homeAddress);
    LatLng? workCoords = await _geocodeAddress(workAddress);

    if (homeCoords != null && workCoords != null) {
      setState(() {
        _homeCoordinates = homeCoords;
        _workCoordinates = workCoords;
      });
    }
  }
  
  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMarkers();
  }
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSideMenuClosed = true;
  int? selectedCarIndex; // Track which car is selected
  String currAddress = '';
  String homeAddress = '';
  String workAddress = '';
  late LatLng _currentCoordinates;
  late LatLng _destinationCoordinates;
  // String currentAddress = '';
  String destinationAddress = '';

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();
  late GoogleMapController newGoogleMapController;

  //For getting user's current location
  late Position currentPosition;

  // Variables to track user's previous location (for distance threshold)
  double previousLatitude = 0.0;
  double previousLongitude = 0.0;

  // Define polylines
  Map<PolylineId, Polyline> polylines = {};

  // Define markers
  Set<Marker> markers = {};

  void _updateDestination(LatLng destination) async {
      // Set destination coordinates
        setState(() {
          _destinationCoordinates = destination;
        });

        // Reverse geocode destination coordinates to address
        String? address = await _reverseGeocodeCoordinates(destination);
        if (address != null) {
          setState(() {
            destinationAddress = address;
          });
        }
    }

  // Function to check and request location permissions
 

// Function to perform geocoding (address to coordinates)
  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      List<geocoding.Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      print('Geocoding failed: $e');
    }
    return null;
  }

  // Function to perform reverse geocoding (coordinates to address)
  Future<String?> _reverseGeocodeCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude, coordinates.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
    } catch (e) {
      print('Reverse geocoding failed: $e');
    }
    return null;
  }

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
          accuracy: geolocator.LocationAccuracy.high,
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

  // Function to set the initial location of the map  
  late LatLng _pGooglePlex;

  // Function to set the initial location of the map

  Future<void> _setInitialLocation() async {
    await _checkLocationPermission();
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
        ),
      );
      setState(() {
        _pGooglePlex = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print(e); // Handle error, e.g., permission denied
    }
  }

  static const LatLng _kGooglePlex =
      LatLng(37.4220, -122.0841); // Googleplex coordinates

  // Variables to track button position
  double buttonX = 295; // Initial horizontal position
  double buttonY = 600; // Initial vertical position
  Future<BitmapDescriptor> _loadCustomMarkerIcon() async {
    return await BitmapDescriptor.asset(
      ImageConfiguration(size: Size(48, 48)), // Specify the size of the icon
      'assets/car.png', // Path to your custom icon in assets
    );
  }

  // Function to show available cars on the map
  void _showAvailableCarsOnMap() async {
    Set<Marker> carMarkers = {};

    // Example list of available cars with their positions
    List<LatLng> carPositions = [
      const LatLng(37.428, -122.085),
      const LatLng(37.429, -122.086),
      const LatLng(37.430, -122.087),
    ];
    List<String> carTitles = [
      'Car 1',
      'Car 2',
      'Car 3',
    ];
    for (LatLng position in carPositions) {
      carMarkers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          icon: await _loadCustomMarkerIcon(), // Load the custom car icon
          infoWindow:
              InfoWindow(title: carTitles[carPositions.indexOf(position)]),
          // infoWindow: const InfoWindow(title: 'Available Car'),
        ),
      );
    }

    setState(() {
      // Add car markers to the map
      markers.addAll(carMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          mapKey.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(
                      top: 90, bottom: 160, left: 20, right: 20),
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _controllerGoogleMap.complete(controller);
                      newGoogleMapController = controller;
                      locatePosition();
                      // Add available cars to the map
                      _showAvailableCarsOnMap();
                    },
                    polylines: Set<Polyline>.of(polylines.values),
                    mapType: MapType.normal,
                    myLocationButtonEnabled: true,
                    // markers: markers,
                    markers: {
                      // if (currentPosition != null)
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: _pGooglePlex,
                        infoWindow: const InfoWindow(title: 'Current Location'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue),
                      ),
                      Marker(
                        markerId: const MarkerId('destinationLocation'),
                        position: _kGooglePlex,
                        infoWindow:
                            const InfoWindow(title: "destination Location"),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueRed),
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: currAddress.isNotEmpty
                          ? LatLng(currentPosition.latitude, currentPosition.longitude)
                          : _pGooglePlex,
                      zoom: 15,
                    ),
                    //for user's current loc
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    onTap: (LatLng tappedLocation) {
                      // Update the current or destination location based on user tap
                      _updateDestination(tappedLocation); // For example, update destination
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
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: const Text('Current Address'),
                                    subtitle: Text(currAddress.isNotEmpty
                                        ? currAddress
                                        : 'Your current location address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'current');
                                    },
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: const Text('Destination Address'),
                                    subtitle: Text(destinationAddress.isNotEmpty
                                        ? destinationAddress
                                        : 'Your destination address'),
                                    onTap: () {
                                      _showAddressOptionsDialog(
                                          context, 'destination');
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

  void _updateMarkers() {
    setState(() async {
      markers.clear();
      markers.add(
        Marker(
          markerId: const MarkerId('homeLocation'),
          position: _homeCoordinates,
          infoWindow: InfoWindow(title: 'Home: $homeAddress'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('workLocation'),
          position: _workCoordinates,
          infoWindow: InfoWindow(title: 'Work: $workAddress'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentCoordinates,
          infoWindow: InfoWindow(title: 'Current: $currAddress'),
          icon: await BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/pickicon.png',
          ),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('destinationLocation'),
          position: _destinationCoordinates,
          infoWindow: InfoWindow(title: 'Destination: $destinationAddress'),
          icon: await BitmapDescriptor.asset(
            const ImageConfiguration(size: Size(48, 48)),
            'assets/images/desticon.png',
          ),
        ),
      );
    });
  }

}
