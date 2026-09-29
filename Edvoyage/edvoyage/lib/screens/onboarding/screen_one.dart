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
import 'screen_two.dart';

class ScreenOne extends StatefulWidget {
  const ScreenOne({super.key});

  @override
  State<ScreenOne> createState() => _ScreenOneState();
}

class _ScreenOneState extends State<ScreenOne> {
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
                        child: Image.asset(onboarding1),
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
                                        RedDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        GreyDot()
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    BoldText(text: 'Crack your exam confidently'),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size?.wp(6) ?? 24,
                                      ),
                                      child: LateBold(
                                        text:
                                            'Through our well-crafted teaching content from videos, clinical case, mcq, train yourself for the NEXT and NEET exam confidently.',
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
                                                        ScreenTwo()));
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
