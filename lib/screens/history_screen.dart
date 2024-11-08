import 'package:flutter/material.dart';
import 'package:gomatch/components/history_screen/ride_history_list.dart';
import 'package:gomatch/utils/colors.dart';

class HistoryScreen extends StatelessWidget {
  static const String idScreen = "HistoryScreen";

  const HistoryScreen({super.key});

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
