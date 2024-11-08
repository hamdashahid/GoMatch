import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/material.dart';
import 'package:gomatch/providers/appData.dart';
import 'package:gomatch/screens/driver_mode_screen.dart';
import 'package:gomatch/screens/faq_screen.dart';
import 'package:gomatch/screens/history_screen.dart';
import 'package:gomatch/screens/home_screen.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/screens/profile_screen.dart';
import 'package:gomatch/screens/settings_screen.dart';
import 'package:gomatch/screens/signup_screen.dart';
import 'package:gomatch/utils/firebase_ref.dart';
import 'package:provider/provider.dart'; // Import usersRef from firebase_ref.dart

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
      create: (context)=> AppData(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Go-Match',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: HomeScreen.idScreen,
        routes: {
          LoginScreen.idScreen: (context) => LoginScreen(),
          SignupScreen.idScreen: (context) => SignupScreen(),
          HomeScreen.idScreen: (context) => HomeScreen(),
          DriverModeScreen.idScreen: (context) => const DriverModeScreen(),
          FAQScreen.idScreen: (context) => const FAQScreen(),
          HistoryScreen.idScreen: (context) => const HistoryScreen(),
          SettingsScreen.idScreen: (context) => const SettingsScreen(),
          ProfileScreen.idScreen: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
