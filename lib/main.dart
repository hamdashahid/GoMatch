import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/components/map_screen/available_cars.dart';
import 'package:gomatch/components/map_screen/available_seats.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:gomatch/screens/add_route_screen.dart';
import 'package:gomatch/screens/driver_dashboard.dart';
import 'package:gomatch/screens/driver_history_screen.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/screens/driver_profile_screen.dart';
import 'package:gomatch/screens/driver_settings_screen.dart';
import 'package:gomatch/screens/faq_screen.dart';
import 'package:gomatch/screens/history_screen.dart';
import 'package:gomatch/screens/home_screen.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/screens/payment_screen.dart';
import 'package:gomatch/screens/profile_screen.dart';
import 'package:gomatch/screens/settings_screen.dart';
import 'package:gomatch/screens/signup_screen.dart';
import 'package:gomatch/utils/firebase_ref.dart';
import 'package:provider/provider.dart'; // Import usersRef from firebase_ref.dart
import 'package:gomatch/screens/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Go-Match',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // User is logged in, check Firestore collections
              return FutureBuilder<bool>(
                future: _checkUserRole(snapshot.data!.email),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (roleSnapshot.hasData) {
                    // Navigate based on user role
                    if (roleSnapshot.data!) {
                      return DriverModeScreen(); // Redirect to driver mode
                    } else {
                      return HomeScreen(); // Redirect to passenger home screen
                    }
                  }
                  // Handle error or unknown case
                  return const Center(
                      child: Text('Error determining user role.'));
                },
              );
            } else {
              // User is not logged in
              return LoginScreen();
            }
          },
        ),
        routes: {
          LoginScreen.idScreen: (context) => LoginScreen(),
          SignupScreen.idScreen: (context) => SignupScreen(),
          VerificationScreen.idScreen: (context) => VerificationScreen(),
          HomeScreen.idScreen: (context) => HomeScreen(),
          DriverModeScreen.idScreen: (context) => DriverModeScreen(),
          FAQScreen.idScreen: (context) => const FAQScreen(),
          HistoryScreen.idScreen: (context) => const HistoryScreen(),
          SettingsScreen.idScreen: (context) => const SettingsScreen(),
          ProfileScreen.idScreen: (context) => ProfileScreen(),
          SearchScreen.idScreen: (context) => const SearchScreen(),
          PaymentScreen.idScreen: (context) => PaymentScreen(price: ''),
          DriverDashboardScreen.idScreen: (context) => DriverDashboardScreen(),
          DriverProfileScreen.idScreen: (context) => DriverProfileScreen(),
          DriverHistoryScreen.idScreen: (context) => DriverHistoryScreen(),
          DriverSettingsScreen.idScreen: (context) =>
              const DriverSettingsScreen(),
          AddRouteScreen.idScreen: (context) => AddRouteScreen(),
          AvailableCarsScreen.idScreen: (context) => AvailableCarsScreen(),
          AvailableSeatsScreen.idScreen: (context) => AvailableSeatsScreen(),
        },
      ),
    );
  }

  /// Check if the user is a driver or a passenger
  Future<bool> _checkUserRole(String? email) async {
    if (email == null) return false;

    final driverCollection =
        FirebaseFirestore.instance.collection('driver_profile');
    final passengerCollection =
        FirebaseFirestore.instance.collection('passenger_profile');

    // Check if email exists in 'driver_profile'
    final driverSnapshot =
        await driverCollection.where('email', isEqualTo: email).get();
    if (driverSnapshot.docs.isNotEmpty) {
      return true; // User is a driver
    }

    // Check if email exists in 'passenger_profile'
    final passengerSnapshot =
        await passengerCollection.where('email', isEqualTo: email).get();
    if (passengerSnapshot.docs.isNotEmpty) {
      return false; // User is a passenger
    }

    // If not found in either collection, default to passenger
    return false;
  }
}
