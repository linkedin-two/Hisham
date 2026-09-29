import 'package:flutter/material.dart';
import '../data/models/school_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class QuizResultsScreen extends StatelessWidget {
  final AppState state;
  final Quiz? quiz;
  final VoidCallback onBack;

  const QuizResultsScreen({
    super.key,
    required this.state,
    this.quiz,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final activeQuiz = quiz ?? state.selectedQuizForResults;

    if (activeQuiz == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          title: const Text('Quiz Results'),
        ),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    final attempts = activeQuiz.attempts;
    final totalStudents = state.classInfo?.studentCount ?? state.students.length;
    final avgAcc = attempts.isNotEmpty
        ? (attempts.fold<int>(0, (s, a) => s + a.accuracy) / attempts.length).round()
        : 0;
    final completionPct = totalStudents > 0
        ? ((attempts.length / totalStudents) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${activeQuiz.subject} — ${activeQuiz.title}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Quiz ${activeQuiz.id.replaceAll('QUIZ-', '')} · ${activeQuiz.questionCount} questions',
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avg Accuracy', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          '$avgAcc%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Completion', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const SizedBox(height: 2),
                        Text(
                          '$completionPct%',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Student Performance',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            if (attempts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('No student attempts logged for this quiz yet.'),
                ),
              )
            else
              ...attempts.map((attempt) {
                final student = state.students.firstWhere(
                  (s) => s.id == attempt.studentId,
                  orElse: () => Student(
                    id: attempt.studentId,
                    name: attempt.studentId,
                    roll: '',
                    attendancePercent: 0,
                    mcqAttempts: 0,
                  ),
                );

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                student.roll,
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                              '${attempt.accuracy}% accuracy',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
