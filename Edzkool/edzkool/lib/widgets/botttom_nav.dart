import 'package:flutter/material.dart';
import 'package:edzkool/screens/notes/notes.dart';
import 'package:edzkool/screens/profile/profile_Screen.dart';
import 'package:edzkool/screens/home_screen/homeScreen.dart';
import 'package:edzkool/screens/cavity_screen/main.dart';
import 'package:edzkool/screens/google_meet/google_meet_handler.dart';
import 'package:edzkool/constants/bottom_nav_assets.dart';
import 'package:edzkool/utils/colors/colors.dart';

class BottomButton extends StatefulWidget {
  const BottomButton({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  final Function()? onTap;
  final int selectedIndex;

  @override
  State<BottomButton> createState() => _BottomButtonState();
}

class _BottomButtonState extends State<BottomButton> {
  late int _selectedIndex;

  int _safeIndex(int raw, int itemCount) {
    if (itemCount <= 0) return 0;
    if (raw < 0) return 0;
    if (raw >= itemCount) return itemCount - 1;
    return raw;
  }

  /// Meet (index 4) is an external action, not a selectable tab.
  int _normalizeSelectedIndex(int raw) {
    if (raw == 4) return 3;
    return _safeIndex(raw, 5);
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _normalizeSelectedIndex(widget.selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    final labelTextStyle = Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(fontFamily: 'Roboto', fontSize: 8.0);

    final items = <BottomNavigationBarItem>[
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
        icon: ImageIcon(AssetImage("assets/book.png")),
        label: 'NOTES',
      ),
      BottomNavigationBarItem(
        icon: ImageIcon(AssetImage(BottomNavAssets.flight)),
        label: 'MEET',
      ),
    ];

    final safeCurrentIndex = _normalizeSelectedIndex(_selectedIndex);

    return SizedBox(
      height: 50.0,
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: secondaryColor,
        unselectedItemColor: primaryColor,
        currentIndex: safeCurrentIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle: labelTextStyle,
        unselectedLabelStyle: labelTextStyle,
        onTap: (index) {
          if (index == 4) {
            handleGoogleMeetNavTap(context);
            widget.onTap?.call();
            return;
          }

          setState(() {
            _selectedIndex = _safeIndex(index, items.length);
          });

          switch (_selectedIndex) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              );
              break;
          }

          widget.onTap?.call();
        },
        items: items,
      ),
    );
  }
}
