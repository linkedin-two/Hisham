import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:edvoyage/screens/login/sign_up.dart';
import 'package:edvoyage/screens/home_screen/homeScreen.dart';
import 'package:edvoyage/screens/splash/splash_screen.dart' as onboarding;
import 'package:edvoyage/screens/Notes/flashcardnotes/data.dart';
import 'package:edvoyage/providers/user_email_provider.dart';
import 'package:edvoyage/_env/env.dart';
import 'package:edvoyage/utils/session_manager.dart';
import 'package:http/http.dart' as http;

// Environment mode: DEBUG = localhost, PRODUCTION = VPS
const String ENV_URL = 'DEBUG';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run runApp immediately so UI loads without waiting for network requests
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // Pre-load flashcards in background asynchronously after UI mounts
  fetchFlashcards().catchError((_) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EdVoyage',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AppStartupGate(),
    );
  }
}

class AppStartupGate extends StatefulWidget {
  const AppStartupGate({super.key});

  @override
  State<AppStartupGate> createState() => _AppStartupGateState();
}

class _AppStartupGateState extends State<AppStartupGate> {
  late final Future<bool> _developerModeFuture;

  @override
  void initState() {
    super.initState();
    _developerModeFuture = _fetchDeveloperMode();
  }

  Future<bool> _fetchDeveloperMode() async {
    try {
      final uri = Uri.parse('${BaseUrl.baseUrlApi}/api/v1/config/');
      final res = await http.get(uri).timeout(const Duration(seconds: 3));
      if (res.statusCode < 200 || res.statusCode >= 300) return true;
      final decoded = jsonDecode(res.body);
      final dynamic value = decoded is Map ? decoded['developer_mode'] : null;
      if (value is bool) return value;
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _developerModeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool developerMode = snapshot.data ?? true;

        if (!developerMode) {
          return const onboarding.SplashScreen();
        }

        return const DevSplashScreen();
      },
    );
  }
}

class DevSplashScreen extends ConsumerStatefulWidget {
  const DevSplashScreen({super.key});

  @override
  ConsumerState<DevSplashScreen> createState() => _DevSplashScreenState();
}

class _DevSplashScreenState extends ConsumerState<DevSplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = await SessionManager.isLoggedIn();
    final userEmail = await SessionManager.getUserEmail();

    if (isLoggedIn && userEmail != null && userEmail.isNotEmpty) {
      // User is logged in, restore email in provider and go to home
      ref.read(userEmailProvider.notifier).state = userEmail;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    if (kUseDevDefaultEmail) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignUp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final double iconSize = (w * 0.06).clamp(24.0, 40.0);
    final double fontSize = (w * 0.055).clamp(18.0, 28.0);
    final double spacing = (h * 0.03).clamp(12.0, 24.0);
    final double horizontalPadding = (w * 0.08).clamp(16.0, 48.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school, size: iconSize, color: Colors.teal),
              SizedBox(height: spacing),
              Text(
                'EdVoyage',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: spacing),
              SizedBox(
                width: (w * 0.2).clamp(60.0, 120.0),
                height: (h * 0.006).clamp(3.0, 6.0),
                child: const CircularProgressIndicator(
                  color: Colors.teal,
                  strokeWidth: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
