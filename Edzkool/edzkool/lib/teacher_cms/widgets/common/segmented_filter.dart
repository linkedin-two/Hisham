import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable Segmented Pill Filter Buttons (All, Completed, In Progress).
class SegmentedFilter extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterSelected;

  const SegmentedFilter({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'completed', 'label': 'Completed'},
      {'key': 'in_progress', 'label': 'In Progress'},
    ];

    return Row(
      children: filters.map((f) {
        final key = f['key']!;
        final label = f['label']!;
        final isActive = activeFilter == key;

        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () => onFilterSelected(key),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : AppColors.surface,
                border: isActive ? null : Border.all(color: AppColors.border),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),

                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
