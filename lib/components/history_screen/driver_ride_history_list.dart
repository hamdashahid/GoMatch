import 'package:flutter/material.dart';
import 'driver_ride_history_tile.dart';

class RideHistoryList extends StatelessWidget {
  const RideHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        RideHistoryTile(
          date: '20 Jun, 05:44 pm',
          pickupLocation: 'Wah Model town Phase 1 Rd 9',
          dropLocation: '17 Qabristan Road',
          fare: 'Rs330.00',
        ),
        RideHistoryTile(
          date: '8 Jun, 12:25 pm',
          pickupLocation: 'A.K. Brohi Road 3',
          dropLocation: 'Wah Model Town Phase 1 Extension',
          fare: 'Rs0.00',
          cancelled: true,
        ),
      ],
    );
  }
}
