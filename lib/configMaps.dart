import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:gomatch/components/home_screen/car_card.dart';
import 'package:gomatch/components/map_screen/available_cars.dart';
import 'package:gomatch/components/side_drawer/side_menu.dart';
import 'package:gomatch/utils/colors.dart'; // For getting the current location

class MapPage extends StatefulWidget {
  GeoPoint? pickupLocation;
  GeoPoint? destinationLocation;
  String? pickupAddress;
  String? destinationAddress;

  MapPage(
      {this.pickupLocation,
      this.destinationLocation,
      this.pickupAddress,
      this.destinationAddress,
      super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController controller;
  bool hasMarkers = false; // Track if markers and route are already added
  bool isSideMenuClosed = true;
  double buttonX = 295; // Initial horizontal position
  double buttonY = 600; // Initial vertical position
  // late MapboxMapController newGoogleMapController;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    // Initialize the MapController without performing any actions yet
    controller = MapController(
      initPosition: GeoPoint(
          latitude: 47.4358055, longitude: 8.4737324), // Default position
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );
  }

  // Function to get current location if pickupLocation is not provided
  Future<void> _getCurrentLocation() async {
    // Request permission to access location
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    // Update the pickup location with the current position
    GeoPoint currentLocation =
        GeoPoint(latitude: position.latitude, longitude: position.longitude);
    setState(() {
      if (widget.pickupLocation == null ||
          (widget.pickupLocation!.latitude == 0.0 &&
              widget.pickupLocation!.longitude == 0.0)) {
        widget.pickupLocation =
            currentLocation; // Set the current location as pickup
      }
    });

    if (!hasMarkers) {
      if (widget.pickupLocation != null &&
          widget.destinationLocation != null &&
          !hasMarkers) {
        await _markLocationsAndDrawRoute(
            widget.pickupLocation!, widget.destinationLocation!);
      }

      // await _markLocationsAndDrawRoute(currentLocation,
      //     widget.destinationLocation!); // Mark locations and draw route
    }
  }

  // Function to add markers and draw a route
  Future<void> _markLocationsAndDrawRoute(
      GeoPoint pickup, GeoPoint destination) async {
    if (hasMarkers) return; // Prevent adding markers and route multiple times
    final configs = [
      MultiRoadConfiguration(
        startPoint: pickup,
        destinationPoint: destination,
      ),
      MultiRoadConfiguration(
          startPoint: pickup,
          destinationPoint: destination,
          roadOptionConfiguration: MultiRoadOption(
            roadColor: Colors.orange,
          )),
      MultiRoadConfiguration(
        startPoint: pickup,
        destinationPoint: destination,
      ),
    ];

    // Add markers for pickup and destination
    await controller.addMarker(
      pickup,
      markerIcon: const MarkerIcon(
        icon: Icon(Icons.location_on, color: Colors.green, size: 48),
      ),
    );
    await controller.addMarker(
      destination,
      markerIcon: const MarkerIcon(
        icon: Icon(Icons.flag, color: Colors.red, size: 48),
      ),
    );

    // Draw the road (route) between pickup and destination
    RoadInfo road = await controller.drawRoad(
      pickup,
      destination,
      roadOption: const RoadOption(
        roadColor: Colors.blue,
        roadWidth: 10.0,
      ),
    );
    controller.moveTo(pickup); // Move the camera to the pickup location
    setState(() {
      hasMarkers = true; // Mark that markers and route are added
      calculateAndDisplayDistance(pickup, destination, road);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(isMenuOpen: !isSideMenuClosed),
      appBar: AppBar(
        title:
            Text("Map View", style: TextStyle(color: AppColors.secondaryColor)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OSMFlutter(
              controller: controller,
              onMapIsReady: (isReady) async {
                if (isReady) {
                  _getCurrentLocation(); // Get current location if pickupLocation is not provided
                }
              },
              osmOption: OSMOption(
                userTrackingOption: const UserTrackingOption(
                  enableTracking: true,
                  unFollowUser: false,
                ),
                zoomOption: const ZoomOption(
                  initZoom: 15,
                  minZoomLevel: 3,
                  maxZoomLevel: 19,
                  stepZoom: 1.0,
                ),
                userLocationMarker: UserLocationMaker(
                  personMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.location_history_rounded,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                  directionArrowMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.double_arrow,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Draggable Floating Action Button
          Positioned(
            left: buttonX,
            top: buttonY,
            child: Draggable(
              feedback: Material(
                child: FloatingActionButton(
                  onPressed: () => _showCarpoolBottomSheet(context,
                      widget.pickupAddress!, widget.destinationAddress!),
                  backgroundColor: AppColors.primaryColor,
                  child: const Icon(Icons.directions_car,
                      color: AppColors.secondaryColor),
                ),
              ),
              childWhenDragging: Container(), // Show nothing while dragging
              child: FloatingActionButton(
                onPressed: () => _showCarpoolBottomSheet(context,
                    widget.pickupAddress!, widget.destinationAddress!),
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

  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        geocoding.Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      print("Error in reverse geocoding: $e");
      return "Error in getting address";
    }
  }

  void calculateAndDisplayDistance(
      GeoPoint startPoint, GeoPoint endPoint, RoadInfo roadInfo) async {
    double distance = roadInfo.distance!; // distance in kilometers

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Route Distance"),
          content: Text(
              "The distance between ${widget.pickupAddress} and ${widget.destinationAddress} is ${distance.toStringAsFixed(2)} km."),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCarpoolBottomSheet(
      BuildContext context, String pickup, String dropoff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize:
              0.8, // Adjust the initial height of the bottom sheet
          minChildSize: 0.5,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: AvailableCarsScreen(
                pickup: pickup,
                dropoff: dropoff,
              ),
            );
          },
        );
      },
    );
  }
}
