import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';
import 'widgets/layout/mobile_app_shell.dart';

void main() {
  runApp(const TeacherCMSApp());
}

class TeacherCMSApp extends StatefulWidget {
  const TeacherCMSApp({super.key});

  @override
  State<TeacherCMSApp> createState() => _TeacherCMSAppState();
}

class _TeacherCMSAppState extends State<TeacherCMSApp> {
  late AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.addListener(_onStateChange);
  }

  void _onStateChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _appState.removeListener(_onStateChange);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher CMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: MobileAppShell(state: _appState),
    );
  }
}
