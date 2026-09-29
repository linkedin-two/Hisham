import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Reusable search input field with icon & clear button.
class SearchField extends StatelessWidget {
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.hintText,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        suffixIcon: value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                onPressed: () => onChanged(''),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
