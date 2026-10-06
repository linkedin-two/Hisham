import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:edzkool/services/update_service.dart';
import 'package:edzkool/_env/env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/_env/env.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import 'package:edzkool/screens/home_screen/homeScreen.dart';
import 'package:edzkool/screens/login/sign_in.dart';
import 'package:edzkool/teacher_cms/widgets/layout/mobile_app_shell.dart';
import 'package:edzkool/teacher_cms/state/app_state.dart';
import 'package:edzkool/utils/authenticated_http.dart';
import 'package:edzkool/utils/avatar.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/session_manager.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    bool isMandatory = await UpdateService.checkForUpdates(context, BaseUrl.baseUrlApi);
    if (isMandatory) return; // Stop the flow, force update
    _checkLoginAndNavigate();
  }


  Future<bool> _fetchDeveloperMode() async {
    try {
      final uri = Uri.parse('${BaseUrl.baseUrlApi}/api/v1/config/');
      final res = await AuthenticatedHttp.get(uri, json: false);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final dynamic value = decoded is Map ? decoded['developer_mode'] : null;
        if (value is bool) return value;
      }
    } catch (_) {
      // Ignore — fall through to default below.
    }
    // When the API is unreachable, still show the normal splash + onboarding flow.
    return false;
  }

  Future<void> _checkLoginAndNavigate() async {
    final developerModeFuture = _fetchDeveloperMode();

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final developerMode = await developerModeFuture;
    final isLoggedIn = await SessionManager.isLoggedIn();
    final userEmail = await SessionManager.getUserEmail();
    final userRole = await SessionManager.getUserRole();

    if (userEmail != null && userEmail.isNotEmpty) {
      ref.read(userEmailProvider.notifier).state = userEmail;
    }

    if (isLoggedIn) {
      if (userRole == 'teacher') {
        final teacherAppState = AppState();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MobileAppShell(state: teacherAppState)),
        );
        return;
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }
    }

    if (developerMode && kUseDevDefaultEmail) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignIn(),
      ),
    );
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
              const Spacer(),
              SizedBox(
                height: 400,
                child: Image.asset(companylogo, fit: BoxFit.fitWidth),
              ),
              const Spacer(),
              SizedBox(
                height: 40,
                child: Text(
                  'edzkool Pvt Ltd',
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
