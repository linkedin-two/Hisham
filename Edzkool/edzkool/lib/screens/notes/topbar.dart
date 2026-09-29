import 'package:flutter/material.dart';

class Topbar extends StatelessWidget {
  final String firstText;
  final String secondText;
  final VoidCallback? onFirstTap;
  final VoidCallback? onSecondTap;

  const Topbar({
    super.key,
    required this.firstText,
    required this.secondText,
    this.onFirstTap,
    this.onSecondTap,
  });

  @override
  Widget build(BuildContext context) {
    // This is the teal color used in your screenshot
    const Color linkColor = Color(0xFF144787);
    final w = MediaQuery.of(context).size.width;
    final fontSize = w * 0.04;
    final iconSize = w * 0.06;
    final TextStyle linkStyle = TextStyle(
      fontFamily: 'Poppins',
      color: linkColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );
    final TextStyle separatorStyle = TextStyle(
      fontFamily: 'Poppins',
      color: linkColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The icon at the beginning
          Icon(Icons.menu_book, color: linkColor, size: iconSize),
          const SizedBox(width: 8),

          // The first separator
          Text(" / ", style: separatorStyle),

          Flexible(
              child: Text(firstText,
                  style: linkStyle, overflow: TextOverflow.ellipsis)),

          // The second separator
          Text(" / ", style: separatorStyle),

          Flexible(
              child: Text(secondText,
                  style: linkStyle, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
