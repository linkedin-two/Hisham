import 'package:flutter/material.dart';
import 'package:edzkool/screens/timer/main.dart';
import 'package:edzkool/widgets/botttom_nav.dart';

class StudyAbroadScreen extends StatefulWidget {
  const StudyAbroadScreen({super.key});

  @override
  _StudyAbroadScreenState createState() => _StudyAbroadScreenState();
}

class _StudyAbroadScreenState extends State<StudyAbroadScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Hero Image
            _buildHeroImage(),

            SizedBox(height: 24),

            // Action Button
            _buildActionButton(),

            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomButton(onTap: () {}, selectedIndex: 3),
    );
  }



  /// Builds the action button
  Widget _buildActionButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Navigate to course finder or slot booking screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TimerScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF5E5B), // Coral red
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          'Begin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  /// Builds responsive hero image with production-grade design
  Widget _buildHeroImage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = MediaQuery.of(context).size.height;

        // Responsive sizing based on device type
        double imageWidth;
        double imageHeight;
        double horizontalPadding;
        double verticalMargin;

        // Breakpoints for responsive design
        if (screenWidth >= 1200) {
          // Large desktop/web
          imageWidth = screenWidth * 0.4;
          imageHeight = screenHeight * 0.35;
          horizontalPadding = 48;
          verticalMargin = 32;
        } else if (screenWidth >= 768) {
          // Tablet
          imageWidth = screenWidth * 0.5;
          imageHeight = screenHeight * 0.3;
          horizontalPadding = 32;
          verticalMargin = 24;
        } else {
          // Mobile
          imageWidth = screenWidth * 0.85;
          imageHeight = screenHeight * 0.75;
          horizontalPadding = 0;
          verticalMargin = 0;
        }

       

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalMargin,
          ),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/api.jpg',
              width: imageWidth,
              height: imageHeight,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: imageWidth,
                  height: imageHeight,
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
