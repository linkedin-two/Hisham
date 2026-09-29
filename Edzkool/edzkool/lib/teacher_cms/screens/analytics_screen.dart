import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/cards/kpi_card.dart';
import '../widgets/common/progress_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  final AppState state;

  const AnalyticsScreen({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceAvg = state.averageAttendancePercentage;
    final avgScore = state.avgScorePercentage;
    final engagement = state.mcqSummary?.classAccuracy ?? 0;
    final completion = state.latestQuizCompletionPercentage;

    // Derive subject averages dynamically
    final Map<String, List<int>> subjectAccuracies = {};
    for (var quiz in state.quizzes) {
      final subject = quiz.subject;
      subjectAccuracies[subject] ??= [];
      for (var attempt in quiz.attempts) {
        subjectAccuracies[subject]!.add(attempt.accuracy);
      }
    }

    final lowSubjects = <String>[];
    subjectAccuracies.forEach((subj, accList) {
      if (accList.isNotEmpty) {
        final avg = (accList.reduce((a, b) => a + b) / accList.length).round();
        if (avg < 75) {
          lowSubjects.add(subj);
        }
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid (2x2)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              KpiCard(value: '$attendanceAvg%', label: 'Attendance'),
              KpiCard(value: '$avgScore%', label: 'Avg Score'),
              KpiCard(value: '$engagement%', label: 'MCQ Accuracy'),
              KpiCard(value: '$completion%', label: 'Completion'),
            ],
          ),
          const SizedBox(height: 16),

          // Attendance Trend Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Trend (recent)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...state.attendanceHistory.map((a) {
                    final pct = ((a.present / a.total) * 100).round();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              a.date.length > 5 ? a.date.substring(5) : a.date,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100.0,
                                backgroundColor: AppColors.border,
                                color: AppColors.secondary,
                                minHeight: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 35,
                            child: Text(
                              '$pct%',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Subject Averages Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subject Averages',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  ...subjectAccuracies.entries.map((entry) {
                    final subj = entry.key;
                    final accList = entry.value;
                    final avg = accList.isNotEmpty
                        ? (accList.reduce((a, b) => a + b) / accList.length).round()
                        : 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(subj, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                              Text('$avg%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          GradientProgressBar(percentage: avg.toDouble()),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Insights Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Teacher Insights',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Class average score $avgScore%. Attendance $attendanceAvg%.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  if (lowSubjects.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Subjects needing attention: ${lowSubjects.join(', ')}',
                            style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
