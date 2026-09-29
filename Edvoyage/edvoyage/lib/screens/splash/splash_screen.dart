import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edvoyage/utils/avatar.dart';
import 'package:edvoyage/utils/colors/colors.dart';
import 'package:edvoyage/screens/onboarding/screen_one.dart';
import 'package:edvoyage/utils/session_manager.dart';
import 'package:edvoyage/screens/home_screen/homeScreen.dart';
import 'package:edvoyage/providers/user_email_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    // Wait for splash duration
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Check if user is already logged in and initialize email
      final isLoggedIn = await SessionManager.isLoggedIn();
      final userEmail = await SessionManager.getUserEmail();

      if (userEmail != null && userEmail.isNotEmpty) {
        // Initialize the email provider with stored email
        ref.read(userEmailProvider.notifier).state = userEmail;
      }

      if (isLoggedIn && userEmail != null && userEmail.isNotEmpty) {
        // User is logged in, navigate to home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // User not logged in, continue with onboarding
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => ScreenOne(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Spacer(),
              SizedBox(
                height: 400, // Replace with the actual height
                child: Image.asset(companylogo, fit: BoxFit.fitWidth),
              ),
              Spacer(),
              SizedBox(
                height: 40, // Replace with the actual height
                child: Text(
                  'edvoyage Pvt Ltd',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
