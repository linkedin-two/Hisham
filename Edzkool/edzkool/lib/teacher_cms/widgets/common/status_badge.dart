import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable status badge for quiz completion state or student status.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toLowerCase() == 'completed';
    final label = isCompleted ? 'completed' : 'in_progress';
    final bgColor = isCompleted ? AppColors.success : AppColors.warning;
    final textColor = isCompleted ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
