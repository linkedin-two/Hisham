import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/cards/student_card.dart';
import '../widgets/common/search_field.dart';

class ClassScreen extends StatelessWidget {
  final AppState state;
  final Function(String studentId) onOpenStudentProfile;

  const ClassScreen({
    super.key,
    required this.state,
    required this.onOpenStudentProfile,
  });

  @override
  Widget build(BuildContext context) {
    final students = state.filteredStudents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            hintText: 'Search students by name or roll',
            value: state.studentSearchQuery,
            onChanged: state.setStudentSearchQuery,
          ),
          const SizedBox(height: 12),

          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text(
                  'No students found.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...students.map((student) {
              return StudentCard(
                student: student,
                onViewProfile: () => onOpenStudentProfile(student.id),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
