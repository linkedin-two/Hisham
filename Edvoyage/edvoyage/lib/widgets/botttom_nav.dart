import 'package:flutter/material.dart';
import 'package:edvoyage/screens/notes/notes.dart';
import 'package:edvoyage/screens/profile/profile_Screen.dart';
import 'package:edvoyage/screens/home_screen/homeScreen.dart';
import 'package:edvoyage/screens/cavity_screen/main.dart';
import 'package:edvoyage/screens/studyabroadnew/main.dart';
import 'package:edvoyage/utils/colors/colors.dart';

class BottomButton extends StatefulWidget {
  const BottomButton({
    super.key,
    required this.onTap,
    required this.selectedIndex,
  });

  final Function()? onTap;
  final int selectedIndex;

  @override
  _BottomButtonState createState() => _BottomButtonState();
}

class _BottomButtonState extends State<BottomButton> {
  late int _selectedIndex;

  int _safeIndex(int raw, int itemCount) {
    if (itemCount <= 0) return 0;
    if (raw < 0) return 0;
    if (raw >= itemCount) return itemCount - 1;
    return raw;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _safeIndex(widget.selectedIndex, 5);
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
        icon: ImageIcon(AssetImage("assets/airplane.png")),
        label: 'FLIGHT',
      ),
    ];

    final safeCurrentIndex = _safeIndex(_selectedIndex, items.length);

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
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudyAbroadScreen()),
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
