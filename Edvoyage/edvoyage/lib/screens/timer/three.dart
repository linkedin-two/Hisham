

import 'package:flutter/material.dart';
import 'package:edvoyage/utils/colors/colors.dart';

class three extends StatelessWidget {
  final VoidCallback onStartPressed;

  const three({super.key, required this.onStartPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: ElevatedButton(
        onPressed: onStartPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.015,
            horizontal: size.width * 0.25,
          ),
        ),
        child: Text(
          'Start',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.06,
          ),
        ),
      ),
    );
  }
}
