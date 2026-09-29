import 'package:flutter/material.dart';
import '../../utils/avatar.dart';
import '../../utils/colors/backgroundColor.dart';
import '../../utils/colors/colors.dart';
import '../../utils/responsive.dart';
import '../../widgets/backgroundImage.dart';
import '../../widgets/dots/grey_dot.dart';
import '../../widgets/dots/red_dot.dart';
import '../../widgets/long_button.dart';
import '../../widgets/onboardingbold.dart';
import '../login/sign_up.dart';

class ScreenFour extends StatefulWidget {
  const ScreenFour({super.key});

  @override
  State<ScreenFour> createState() => _ScreenFourState();
}

class _ScreenFourState extends State<ScreenFour> {
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
                        child: Image.asset(onboarding4),
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
                                        GreyDot(),
                                        SizedBox(width: size?.wp(2)),
                                        RedDot(),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    BoldText(text: 'Interact with professionals'),
                                    const SizedBox(height: 12),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: size?.wp(6) ?? 24,
                                      ),
                                      child: LateBold(
                                        text:
                                            'Get your questions answered by some of the best lectures or doctors around the globe through the medico hub CAVITY.post your questions or doubts and engage with professionals.',
                                      ),
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 25, right: 25, bottom: 12),
                                      child: LongButton(
                                        text: 'Get Started',
                                        action: () {
                                          Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) =>
                                                      SignUp()));
                                        },
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
