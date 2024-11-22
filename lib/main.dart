import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:gomatch/components/home_screen/search_screen.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:gomatch/screens/driver_dashboard.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
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
        // Use StreamBuilder to check authentication status and set initial route accordingly
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(), // Listen to auth state changes
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while checking the auth state
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              // User is logged in, navigate to HomeScreen
              return HomeScreen();
            } else {
              // User is not logged in, navigate to LoginScreen
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
          PaymentScreen.idScreen: (context) => const PaymentScreen(),
          DashboardScreen.idScreen: (context) => DashboardScreen(),
        },
      ),
    );
  }


  
}
