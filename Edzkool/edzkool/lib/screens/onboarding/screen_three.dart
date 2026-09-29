import 'package:flutter/material.dart';
import '../../utils/avatar.dart';
import '../../utils/colors/backgroundColor.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/backgroundImage.dart';
import '../../widgets/dots/grey_dot.dart';
import '../../widgets/dots/red_dot.dart';
import '../../widgets/onboarding_button.dart';
import '../../widgets/onboardingbold.dart';
import '../../widgets/skipButton.dart';
import 'screen_four.dart';

class ScreenThree extends StatefulWidget {
  const ScreenThree({super.key});

  @override
  State<ScreenThree> createState() => _ScreenThreeState();
}

class _ScreenThreeState extends State<ScreenThree> {
  Measurements? size;
  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Stack(
          children: [
            BackgroundColor(),
            BackgroundImage(),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 55,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Image.asset(onboarding3),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 45,
                    child: Container(
                      width: size?.wp(100),
                      decoration: BoxDecoration(
                        color: thirdColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(110),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        RedDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot()
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    BoldText(text: "Medico's mutual friend"),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size?.wp(6) ?? 24,
                                      ),
                                      child: LateBold(
                                        text:
                                            'Keep all your medico friend and colleagues in a single hub, connect with them in our in-app messenger on the go.',
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 25, right: 25, bottom: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SkipButton(),
                                          OnboardingButton(action: () {
                                            Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                    pageBuilder: (_, __, ___) =>
                                                        ScreenFour()));
                                          })
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
