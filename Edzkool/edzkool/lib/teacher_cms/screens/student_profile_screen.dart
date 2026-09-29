import 'package:flutter/material.dart';
import '../data/models/school_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class StudentProfileScreen extends StatefulWidget {
  final AppState state;
  final Student? student;
  final VoidCallback onBack;
  final Function(String quizId) onOpenQuizResults;

  const StudentProfileScreen({
    super.key,
    required this.state,
    this.student,
    required this.onBack,
    required this.onOpenQuizResults,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStudent = widget.student ?? widget.state.selectedStudentForProfile;

    if (activeStudent == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
          title: const Text('Student Profile'),
        ),
        body: const Center(child: Text('Student not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeStudent.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              activeStudent.roll,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // KPI Metric Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Attendance', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${activeStudent.attendancePercent}%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: AppColors.border),
                Column(
                  children: [
                    const Text('MCQ Attempts', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${activeStudent.mcqAttempts}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Quizzes'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('demo@example.edu', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    const Divider(height: 24),
                    const Text('Academic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      widget.state.classInfo?.program ?? 'Medical Entrance Program',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const Divider(height: 24),
                    const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('• Completed 3 quizzes this month', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '• MCQ practice: ${activeStudent.mcqAttempts} attempts',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),

                // Quizzes Tab
                ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: widget.state.quizzes.map((quiz) {
                    final attempt = quiz.attempts.firstWhere(
                      (a) => a.studentId == activeStudent.id,
                      orElse: () => QuizAttempt(
                        studentId: '',
                        score: 0,
                        total: 0,
                        correct: 0,
                        incorrect: 0,
                        accuracy: 0,
                      ),
                    );

                    if (attempt.total == 0) return const SizedBox.shrink();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${quiz.subject} — ${quiz.title}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Quiz ${quiz.id.replaceAll("QUIZ-", "")}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${attempt.score} / ${attempt.total}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${attempt.accuracy}%',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => widget.onOpenQuizResults(quiz.id),
                              child: const Text('View →', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
