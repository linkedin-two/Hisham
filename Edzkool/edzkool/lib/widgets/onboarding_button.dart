import 'package:flutter/material.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';

class OnboardingButton extends StatelessWidget {
  final VoidCallback action;

  const OnboardingButton({
    super.key,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final size = Measurements(MediaQuery.of(context).size);
    return SizedBox(
        width: size.wp(15),
        height: size.hp(10),
        child: ElevatedButton(
            style: ButtonStyle(
              shape: WidgetStateProperty.all(const CircleBorder()),
              backgroundColor: WidgetStateProperty.all(secondaryColor),
            ),
            onPressed: action,
            child: Container(
              height: size.hp(5),
              width: size.wp(13),
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
