

import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
    required this.orientation,
    required this.verHeight,
    required this.horiHeight,
    required this.verWidth,
    required this.horiWidth,
    required this.cardTitle,
    required this.cardBalance,
  }) : super(key: key);

  final Orientation orientation;
  final double verHeight;
  final double horiHeight;
  final double verWidth;
  final double horiWidth;
  final String cardTitle;
  final String cardBalance;

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = verHeight * 0.23; // Adjust for larger font
    final double balanceFontSize = verHeight * 0.2; // Adjust for larger font

    return Container(
      height: orientation == Orientation.portrait ? verHeight : horiHeight,
      width: orientation == Orientation.portrait ? verWidth : horiWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _truncateText(cardTitle, 15), // Truncate title if too long
              style: TextStyle(
                fontSize: titleFontSize,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8), // Increase spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 20, // Increase icon size
                ),
                SizedBox(
                  height: verHeight * 0.3, // Adjust text container height
                  child: Text(
                    cardBalance,
                    style: TextStyle(
                      fontSize: balanceFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    return (text.length > maxLength) ? '${text.substring(0, maxLength)}...' : text;
  }
}
