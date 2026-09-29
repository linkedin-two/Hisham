import 'package:flutter/material.dart';
import '../../../_env/env.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/class_screen.dart';
import '../../screens/attendance_screen.dart';
import '../../screens/quizzes_screen.dart';
import '../../screens/analytics_screen.dart';
import '../../screens/quiz_results_screen.dart';
import '../../screens/student_profile_screen.dart';
import 'mobile_header.dart';

/// Main Mobile App Shell wrapping the Bottom Navigation Bar, Safe Areas,
/// Top App Header, and Single Page Navigation transitions.
class MobileAppShell extends StatefulWidget {
  final AppState state;

  const MobileAppShell({
    super.key,
    required this.state,
  });

  @override
  State<MobileAppShell> createState() => _MobileAppShellState();
}

class _MobileAppShellState extends State<MobileAppShell> {
  // Navigation stack for drill-down views (Results, Student Profile)
  Widget? _activeOverlayScreen;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onAppStateChanged);
  }

  @override
  void didUpdateWidget(covariant MobileAppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      oldWidget.state.removeListener(_onAppStateChanged);
      widget.state.addListener(_onAppStateChanged);
    }
  }

  @override
  void dispose() {
    widget.state.removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _onAppStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _openQuizResults(String quizId) {
    final quiz = widget.state.quizzes.firstWhere(
      (q) => q.id == quizId,
      orElse: () => widget.state.quizzes.first,
    );
    widget.state.selectQuizForResults(quiz);
    setState(() {
      _activeOverlayScreen = QuizResultsScreen(
        state: widget.state,
        quiz: quiz,
        onBack: () => setState(() => _activeOverlayScreen = null),
      );
    });
  }

  void _openStudentProfile(String studentId) {
    final student = widget.state.students.firstWhere(
      (s) => s.id == studentId,
      orElse: () => widget.state.students.first,
    );
    widget.state.selectStudentProfile(student);
    setState(() {
      _activeOverlayScreen = StudentProfileScreen(
        state: widget.state,
        student: student,
        onBack: () => setState(() => _activeOverlayScreen = null),
        onOpenQuizResults: _openQuizResults,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final classSubtitle = state.classInfo != null
        ? '${state.classInfo!.name} · ${state.classInfo!.studentCount} students'
        : 'Class 1';

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (state.hasError) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 64,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Backend Connection Error',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unable to connect to Django REST API server.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Ensure backend API server is active:\n${BaseUrl.baseUrlApi}\n(or local: python manage.py runserver)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => state.loadData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Connection'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_activeOverlayScreen != null) {
      return _activeOverlayScreen!;
    }

    final screens = [
      DashboardScreen(
        state: state,
        onOpenQuizResults: _openQuizResults,
      ),
      ClassScreen(
        state: state,
        onOpenStudentProfile: _openStudentProfile,
      ),
      AttendanceScreen(state: state),
      QuizzesScreen(
        state: state,
        onOpenQuizResults: _openQuizResults,
      ),
      AnalyticsScreen(state: state),
    ];

    final titles = [
      'Quizzes & MCQs',
      'My Class',
      'Attendance',
      'Quizzes',
      'Analytics & Insights',
    ];

    final subtitles = [
      classSubtitle,
      classSubtitle,
      'Mark present/absent — Django API sync',
      'List of quizzes and drill-down',
      classSubtitle,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileHeader(
        title: titles[state.selectedTabIndex],
        subtitle: subtitles[state.selectedTabIndex],
        onProfileTap: () {
          if (state.students.isNotEmpty) {
            _openStudentProfile(state.students.first.id);
          }
        },
      ),
      body: IndexedStack(
        index: state.selectedTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: state.selectedTabIndex,
          onDestinationSelected: (index) {
            setState(() {
              _activeOverlayScreen = null;
            });
            state.setTabIndex(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.primary),
              label: 'Class',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
              label: 'Attend',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
              label: 'Quiz',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart, color: AppColors.primary),
              label: 'Analytics',
            ),
          ],
        ),
      ),
    );
  }
}
