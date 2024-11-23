import 'package:flutter/material.dart';
import 'package:gomatch/components/history_screen/driver_ride_history_list.dart';
import 'package:gomatch/utils/colors.dart';

class DriverHistoryScreen extends StatelessWidget {
  static const String idScreen = "DriverHistoryScreen";

  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My rides"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const RideHistoryList(),
    );
  }
}
