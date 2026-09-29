import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/cards/kpi_card.dart';
import '../widgets/cards/quiz_card.dart';
import '../widgets/common/search_field.dart';
import '../widgets/common/segmented_filter.dart';

class DashboardScreen extends StatelessWidget {
  final AppState state;
  final Function(String quizId) onOpenQuizResults;

  const DashboardScreen({
    super.key,
    required this.state,
    required this.onOpenQuizResults,
  });

  @override
  Widget build(BuildContext context) {
    final filteredQuizzes = state.filteredDashboardQuizzes;
    final totalStudents = state.classInfo?.studentCount ?? state.students.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2x2 KPI Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: [
              KpiCard(
                value: '${state.totalQuizzesCount}',
                label: 'Quizzes',
              ),
              KpiCard(
                value: '${state.avgScorePercentage}%',
                label: 'Avg Score',
              ),
              KpiCard(
                value: '${state.latestQuizCompletionPercentage}%',
                label: 'Completion',
              ),
              KpiCard(
                value: '${state.avgAccuracyPercentage}%',
                label: 'Avg Accuracy',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Filter controls
          SearchField(
            hintText: 'Search quizzes, subjects, topics',
            value: state.dashboardSearchQuery,
            onChanged: state.setDashboardSearchQuery,
          ),
          const SizedBox(height: 10),

          SegmentedFilter(
            activeFilter: state.quizFilter,
            onFilterSelected: state.setQuizFilter,
          ),
          const SizedBox(height: 16),

          // Quiz Cards List
          if (filteredQuizzes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No quizzes found matching filters.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...filteredQuizzes.map((quiz) {
              return QuizCard(
                quiz: quiz,
                totalStudents: totalStudents,
                onViewResults: () => onOpenQuizResults(quiz.id),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
