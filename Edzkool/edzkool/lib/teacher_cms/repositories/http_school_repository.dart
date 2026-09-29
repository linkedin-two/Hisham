import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../_env/env.dart';
import '../models/school_models.dart';
import 'school_repository.dart';

/// Pure REST API Repository connecting Flutter Mobile SPA to Django REST Framework API.
/// No mock data or fallbacks. Throws explicit exceptions when backend server is unreachable.
class HttpSchoolRepository implements SchoolRepository {
  final String baseUrl;
  final http.Client _client;

  HttpSchoolRepository({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? '${BaseUrl.baseUrl}/teacher',
        _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  @override
  Future<Teacher> getTeacher() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/teacher/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return Teacher.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch teacher profile from Django API (Status ${response.statusCode})');
  }

  @override
  Future<ClassInfo> getClassInfo() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/class/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return ClassInfo.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch class info from Django API (Status ${response.statusCode})');
  }

  @override
  Future<List<Student>> getStudents() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/students/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((json) => Student.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch students from Django API (Status ${response.statusCode})');
  }

  @override
  Future<List<AttendanceRecord>> getAttendanceHistory() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/attendance/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((json) => AttendanceRecord.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch attendance history from Django API (Status ${response.statusCode})');
  }

  @override
  Future<List<Quiz>> getQuizzes() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/quizzes/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((json) => Quiz.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch quizzes from Django API (Status ${response.statusCode})');
  }

  @override
  Future<MCQSummary> getMCQSummary() async {
    final response = await _client
        .get(Uri.parse('$baseUrl/mcq-summary/'), headers: _headers)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      return MCQSummary.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch MCQ summary from Django API (Status ${response.statusCode})');
  }

  @override
  Future<void> updateStudentAttendance(String studentId, bool isPresent) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/attendance/update/'),
      headers: _headers,
      body: jsonEncode({
        'studentId': studentId,
        'isPresent': isPresent,
      }),
    ).timeout(const Duration(seconds: 5));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update attendance on Django API (Status ${response.statusCode})');
    }
  }
}
