import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable linear gradient progress bar widget.
class GradientProgressBar extends StatelessWidget {
  final double percentage; // 0 to 100
  final double height;

  const GradientProgressBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPct = percentage.clamp(0.0, 100.0) / 100.0;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clampedPct,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.progressBarGradient,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}
