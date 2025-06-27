import 'package:flutter/material.dart';

Widget barColumn({required String day, required double fill}) {
  return Column(
    // mainAxisAlignment: MainAxisAlignment.,
    children: [
      Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background (white bar)
          Container(
            width: 22,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Foreground (green fill)
          Container(
            width: 22,
            height: 80 * fill,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 144, 255, 18),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.zero,
                top: Radius.circular(fill == 1.0 ? 8 : 0),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 3),
      Text(
        day,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    ],
  );
}
