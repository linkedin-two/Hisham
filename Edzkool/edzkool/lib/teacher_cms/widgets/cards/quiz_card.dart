import 'package:flutter/material.dart';
import '../../data/models/school_models.dart';
import '../../theme/app_colors.dart';
import '../common/status_badge.dart';

/// Reusable Quiz Card widget for quiz list views.
class QuizCard extends StatelessWidget {
  final Quiz quiz;
  final int totalStudents;
  final VoidCallback onViewResults;

  const QuizCard({
    super.key,
    required this.quiz,
    required this.totalStudents,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    final attempts = quiz.attempts;
    final avgAcc = attempts.isNotEmpty
        ? (attempts.fold<int>(0, (s, a) => s + a.accuracy) / attempts.length).round()
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.subject,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Quiz ${quiz.id.replaceAll('QUIZ-', '')} · ${quiz.questionCount} questions',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: quiz.status),
                  const SizedBox(height: 4),
                  Text(
                    'Avg: ${avgAcc != null ? "$avgAcc%" : "—"}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    'Completed: ${attempts.length} / $totalStudents',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onViewResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View Results',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
