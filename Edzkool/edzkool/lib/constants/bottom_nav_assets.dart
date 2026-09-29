import 'package:flutter/material.dart';

/// Bottom navigation bar icon asset paths.
/// Use with [bottomNavIcon] — same pattern as existing nav items.
class BottomNavAssets {
  BottomNavAssets._();

  static const String home = 'assets/frame.png';
  static const String search = 'assets/diamonds.png';
  static const String cart = 'assets/Group 98.png';
  static const String notes = 'assets/book.png';
  static const String flight = 'assets/google_meet.png';

  /// Google Meet / video call icon (replaces airplane/flight tab icon).
  static const String googleMeet = flight;

  static const List<String> all = [
    home,
    search,
    cart,
    notes,
    flight,
    googleMeet,
  ];
}

/// Standard bottom-nav icon widget (tinted by BottomNavigationBar colors).
Widget bottomNavIcon(String assetPath) => ImageIcon(AssetImage(assetPath));
