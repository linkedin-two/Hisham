import 'package:flutter/material.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';

class BoldText extends StatelessWidget {
  final String text;

  const BoldText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final size = Measurements(MediaQuery.of(context).size);
    return Container(
      height: size.hp(3),
      width: size.wp(70),
      alignment: Alignment.center,
      child: Text(
        text,
        textScaler: const TextScaler.linear(1.7),
        style: TextStyle(
          fontFamily: 'Roboto',
          color: primaryColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class LateBold extends StatelessWidget {
  final String text;

  const LateBold({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textScaler: const TextScaler.linear(1.25),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'Roboto',
        color: grey3,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
