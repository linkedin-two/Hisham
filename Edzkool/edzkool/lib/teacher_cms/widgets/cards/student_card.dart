import 'package:flutter/material.dart';
import '../../data/models/school_models.dart';
import '../../theme/app_colors.dart';

/// Reusable Student Item Card widget for class list.
class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onViewProfile;

  const StudentCard({
    super.key,
    required this.student,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.roll,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Attend',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Text(
                    '${student.attendancePercent}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: student.attendancePercent >= 75
                          ? AppColors.textPrimary
                          : AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: onViewProfile,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('View', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
