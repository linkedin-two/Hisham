import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';

class AttendanceScreen extends StatefulWidget {
  final AppState state;

  const AttendanceScreen({
    super.key,
    required this.state,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, bool> _sessionAttendance = {};

  @override
  void initState() {
    super.initState();
    _initAttendance();
  }

  void _initAttendance() {
    for (var s in widget.state.students) {
      _sessionAttendance[s.id] = s.isPresent ?? (s.attendancePercent >= 75);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = widget.state.students;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final isPresent = _sessionAttendance[student.id] ?? true;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Attend %',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                            Text(
                              '${student.attendancePercent}%',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isPresent,
                        activeTrackColor: AppColors.primary,

                        onChanged: (val) {
                          setState(() {
                            _sessionAttendance[student.id] = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Present: ${_sessionAttendance.values.where((v) => v).length} / ${students.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  for (var entry in _sessionAttendance.entries) {
                    await widget.state.toggleStudentAttendance(entry.key, entry.value);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attendance saved for this session! KPIs updated.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Save (session)'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
