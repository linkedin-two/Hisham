import 'package:flutter/material.dart';
import 'package:edzkool/utils/colors/colors.dart';

class GoogleMeetClassDialog extends StatefulWidget {
  const GoogleMeetClassDialog({super.key});

  @override
  State<GoogleMeetClassDialog> createState() => _GoogleMeetClassDialogState();
}

class _GoogleMeetClassDialogState extends State<GoogleMeetClassDialog> {
  int _selectedClass = 1;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Poppins'),
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Select Your Class',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your school class (1–10). This will be saved and cannot be changed later.',
              style: TextStyle(
                color: grey3,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedClass,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                        'Class ${index + 1}',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedClass = value);
                          }
                        },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 16, color: secondaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Once submitted, your class cannot be updated.',
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: grey3)),
          ),
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    setState(() => _isSubmitting = true);
                    Navigator.of(context).pop(_selectedClass);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

Future<int?> showGoogleMeetClassDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const GoogleMeetClassDialog(),
  );
}
