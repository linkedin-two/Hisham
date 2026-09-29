import '../models/school_models.dart';

/// Abstract SchoolRepository interface for Teacher CMS.
abstract class SchoolRepository {
  Future<Teacher> getTeacher();
  Future<ClassInfo> getClassInfo();
  Future<List<Student>> getStudents();
  Future<List<AttendanceRecord>> getAttendanceHistory();
  Future<List<Quiz>> getQuizzes();
  Future<MCQSummary> getMCQSummary();
  Future<void> updateStudentAttendance(String studentId, bool isPresent);
}
