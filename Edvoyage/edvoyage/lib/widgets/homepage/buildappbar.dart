import 'package:flutter/material.dart';
import 'package:edvoyage/screens/notification/notification.dart';
import 'package:edvoyage/utils/colors/colors.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final logoWidth = screenWidth * 0.5; // 50% of screen width
  final logoHeight = kToolbarHeight * 0.3; // 30% of app bar height

  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0.2,
    automaticallyImplyLeading: false,
    centerTitle: true,
    title: SizedBox(
      width: logoWidth,
      height: logoHeight,
      child: Image.asset(
        'assets/edvoyage1.png',
        width: logoWidth,
        height: logoHeight,
        fit: BoxFit.contain,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.notifications,
          color: primaryColor,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NotificationScreen()),
          );
        },
      ),
    ],
  );
}
