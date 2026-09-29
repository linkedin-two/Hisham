import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edzkool/utils/BottomNavigation/bottom_navigation.dart';
import 'package:edzkool/constants/bottom_nav_assets.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/screens/cavity_screen/cavity.dart';
import 'package:edzkool/screens/teach_screen/tech_home_screen.dart';
import 'package:edzkool/screens/notes/notes.dart';
import 'package:edzkool/screens/google_meet/google_meet_handler.dart';
import 'happy_mood.dart';

class HappyBottom extends StatefulWidget {
  const HappyBottom({super.key});

  @override
  State<HappyBottom> createState() => _HappyBottomState();
}

class _HappyBottomState extends State<HappyBottom> {
  final List<Widget> _children = [
    // ProfileScreen(),
    FeedScreen(),
    Happy(),
    TeachHome(),
    CategoriesScreen(),
    //  OverseasOne(),
  ];

  int selectedIndex = 2;

  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;
  @override
  Widget build(BuildContext context) {
    final labelTextStyle = Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(fontFamily: 'Roboto', fontSize: 8.0);

    return Obx(() {
      int index = controller.tabIndex.toInt();
      return Scaffold(
        backgroundColor: Color(0xFFEFEFEF),
        body: _children[selectedIndex],
        bottomNavigationBar: SizedBox(
          height: 50.0,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: secondaryColor,
            unselectedItemColor: primaryColor,
            currentIndex: selectedIndex,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            selectedLabelStyle: labelTextStyle,
            unselectedLabelStyle: labelTextStyle,
            onTap: (index) {
              if (index == 4) {
                handleGoogleMeetNavTap(context);
                return;
              }
              setState(() {
                selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/frame.png")),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/diamonds.png")),
                label: 'SEARCH',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/Group 98.png")),
                label: 'CART',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage("assets/bookmark.png")),
                label: 'NOTES',
              ),
              BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(BottomNavAssets.flight)),
                label: 'SEARCH',
              ),
            ],
          ),
        ),
      );
    });
  }
}
