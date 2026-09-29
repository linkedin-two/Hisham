import 'package:flutter/material.dart';
import 'package:edvoyage/utils/colors/colors.dart';

class StopButton extends StatelessWidget {
  final VoidCallback onStopPressed;

  const StopButton({super.key, required this.onStopPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: ElevatedButton(
        onPressed: onStopPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.015,
            horizontal: size.width * 0.25,
          ),
        ),
        child: Text(
          'Stop',
          style: TextStyle(
            color: Colors.white,
            fontSize: size.width * 0.06,
          ),
        ),
      ),
    );
  }
}
