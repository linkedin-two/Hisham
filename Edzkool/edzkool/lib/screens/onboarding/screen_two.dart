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
import 'screen_three.dart';

class ScreenTwo extends StatefulWidget {
  const ScreenTwo({super.key});

  @override
  State<ScreenTwo> createState() => _ScreenTwoState();
}

class _ScreenTwoState extends State<ScreenTwo> {
  Measurements? size;
  @override
  Widget build(BuildContext context) {
    size = Measurements(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: secondaryColor,
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
                        child: Image.asset(onboarding2),
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
                                        RedDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot()
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    BoldText(text: "Study abroad, now easy!"),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size?.wp(6) ?? 24,
                                      ),
                                      child: LateBold(
                                        text:
                                            'Abroad medical admission might sound hectic, but devoyage can help you shortlist and guide you not only through the admission but throughout the academic course.',
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
                                                        ScreenThree()));
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
