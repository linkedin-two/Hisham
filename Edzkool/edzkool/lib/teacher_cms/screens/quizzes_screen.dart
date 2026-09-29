import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/cards/quiz_card.dart';
import '../widgets/common/search_field.dart';

class QuizzesScreen extends StatelessWidget {
  final AppState state;
  final Function(String quizId) onOpenQuizResults;

  const QuizzesScreen({
    super.key,
    required this.state,
    required this.onOpenQuizResults,
  });

  @override
  Widget build(BuildContext context) {
    final query = state.quizSearchQuery.toLowerCase();
    final totalStudents = state.classInfo?.studentCount ?? state.students.length;

    final filteredQuizzes = state.quizzes.where((q) {
      if (query.isEmpty) return true;
      return q.title.toLowerCase().contains(query) ||
          q.subject.toLowerCase().contains(query) ||
          q.id.toLowerCase().contains(query);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            hintText: 'Search quizzes',
            value: state.quizSearchQuery,
            onChanged: state.setQuizSearchQuery,
          ),
          const SizedBox(height: 12),

          if (filteredQuizzes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No quizzes found.',
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
