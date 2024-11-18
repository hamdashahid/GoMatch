import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gomatch/utils/colors.dart'; // For getting the current location

class MapPage extends StatefulWidget {
  GeoPoint? pickupLocation;
  GeoPoint? destinationLocation;

  MapPage({this.pickupLocation, this.destinationLocation, super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapController controller;
  bool hasMarkers = false; // Track if markers and route are already added

  @override
  void initState() {
    super.initState();
    // Initialize the MapController without performing any actions yet
    controller = MapController(
      initPosition:  GeoPoint(latitude: 47.4358055, longitude: 8.4737324), // Default position
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
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
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
    GeoPoint currentLocation = GeoPoint(latitude: position.latitude, longitude: position.longitude);
    setState(() {
      widget.pickupLocation = currentLocation; // Set the current location as pickup
    });

    if (!hasMarkers) {
      await _markLocationsAndDrawRoute(currentLocation, widget.destinationLocation!); // Mark locations and draw route
    }
  }

  // Function to add markers and draw a route
  Future<void> _markLocationsAndDrawRoute(GeoPoint pickup, GeoPoint destination) async {
    if (hasMarkers) return; // Prevent adding markers and route multiple times

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
    await controller.drawRoad(
      pickup,
      destination,
      roadOption: const RoadOption(
        roadColor: Colors.blue,
        roadWidth: 10.0,
      ),
    );

    setState(() {
      hasMarkers = true; // Mark that markers and route are added
    });
  }

  // Function to update the route whenever the locations are updated
  void _updateRoute(GeoPoint pickup, GeoPoint destination) async {
    // Clear existing markers and route
    await controller.removeMarkers( [pickup, destination]);

    // Add updated markers and route
    await _markLocationsAndDrawRoute(pickup, destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map View", style: TextStyle(color: AppColors.secondaryColor)),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: OSMFlutter(
        controller: controller,
        onMapIsReady: (isReady){
          if (isReady) {
            _getCurrentLocation(); // Get current location if pickupLocation is not provided
            if(widget.pickupLocation!=null){
              _updateRoute(widget.pickupLocation!, widget.destinationLocation!);
            }
            // _markLocationsAndDrawRoute(widget.pickupLocation, destination)
            // if (widget.pickupLocation == null) {
            //   _getCurrentLocation(); // Get current location if pickupLocation is not provided
            // } else {
            //   if (!hasMarkers) {
            //     _markLocationsAndDrawRoute(widget.pickupLocation!, widget.destinationLocation!); // Mark locations and draw route
            //   }
            // }
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
    );
  }
}
