import 'package:flutter/material.dart';

class CounterText extends StatelessWidget {
  final int counter;

  const CounterText({super.key, required this.counter});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$counter',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}
