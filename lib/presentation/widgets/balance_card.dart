import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.constraints,
    required this.amount,
  });

  final dynamic constraints;
  final String amount;

  @override
Widget build(BuildContext context) {
  return Stack(
    children: [
      Container(
        height: constraints,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
      ),
      Positioned(
        left: constraints * 0.05, // Adjust left position based on screen width
        top: constraints * 0.05, // Adjust top position based on screen height
        child: Text(
          'Available Balance',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      Positioned(
        left: constraints * 0.04, // Adjust left position based on screen width
        bottom: constraints * 0.09, // Adjust bottom position based on screen height
        child: Icon(
          Icons.currency_rupee, // Use appropriate icon
          color: Colors.white,
          size: constraints * 0.15, // Adjust icon size based on screen height
        ),
      ),
      Positioned(
        left: constraints * 0.12, // Adjust left position based on screen width
        bottom: constraints * 0.08, // Adjust bottom position based on screen height
        child: Text(
          amount,
          style: const TextStyle(
            fontSize: 56,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Positioned(
        right: constraints * 0.02, // Adjust right position based on screen width
        bottom: constraints * 0.04, // Adjust bottom position based on screen height
        child: Text(
          'Batuaa',
          style: TextStyle(
            fontSize: 22,
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

}
