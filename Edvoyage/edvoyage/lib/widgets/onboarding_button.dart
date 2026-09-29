import 'package:flutter/material.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/utils/responsive.dart';

class OnboardingButton extends StatelessWidget {
  late Function() action;

  OnboardingButton({
    super.key,
    required this.action,
  });

  Measurements? size;
  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);
    return SizedBox(
        width: size?.wp(15),
        height: size?.hp(10),
        child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(CircleBorder()),
              backgroundColor: WidgetStateProperty.all(secondaryColor),
            ),
            onPressed: action,
            child: Container(
              height: size?.hp(5),
              width: size?.wp(13),
              decoration:
                  BoxDecoration(color: thirdColor, shape: BoxShape.circle),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(1, 0),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            )));
  }
}
