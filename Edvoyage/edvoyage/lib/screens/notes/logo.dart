import 'package:flutter/material.dart';

const String edvoyagelogo1 = 'assets/edvoyage1.png';

class CustomLogoAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomLogoAppBar({super.key});

  @override
  State<CustomLogoAppBar> createState() => _CustomLogoAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomLogoAppBarState extends State<CustomLogoAppBar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    // Logo sizing - larger logo overflowing normal app bar
    final logoWidth = isMobile ? screenWidth * 0.8 : 400.0; // 2x width
    final logoHeight = isMobile ? 160.0 : 140.0; // 3x height (~56*3=168 but constrained)

    return AppBar(
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF008080),
                size: 30,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: SizedBox(
        width: logoWidth,
        height: logoHeight,
        child: Image.asset(
          'assets/edvoyage1.png',
          width: logoWidth,
          height: logoHeight,
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
    );
  }
}
