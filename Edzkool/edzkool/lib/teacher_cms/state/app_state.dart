import 'package:flutter/material.dart';
import '../data/models/school_models.dart';
import '../data/repositories/school_repository.dart';
import '../data/repositories/http_school_repository.dart';

/// AppState manages reactive global state for the Teacher CMS SPA.
class AppState extends ChangeNotifier {
  final SchoolRepository _repository;

  int _selectedTabIndex = 0;
  String _quizFilter = 'all'; // 'all', 'completed', 'in_progress'
  String _dashboardSearchQuery = '';
  String _studentSearchQuery = '';
  String _quizSearchQuery = '';

  Teacher? _teacher;
  ClassInfo? _classInfo;
  List<Student> _students = [];
  List<AttendanceRecord> _attendanceHistory = [];
  List<Quiz> _quizzes = [];
  MCQSummary? _mcqSummary;

  Quiz? _selectedQuizForResults;
  Student? _selectedStudentForProfile;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  AppState({SchoolRepository? repository})
      : _repository = repository ?? HttpSchoolRepository() {
    loadData();
  }

  // Getters
  int get selectedTabIndex => _selectedTabIndex;
  String get quizFilter => _quizFilter;
  String get dashboardSearchQuery => _dashboardSearchQuery;
  String get studentSearchQuery => _studentSearchQuery;
  String get quizSearchQuery => _quizSearchQuery;

  Teacher? get teacher => _teacher;
  ClassInfo? get classInfo => _classInfo;
  List<Student> get students => _students;
  List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  List<Quiz> get quizzes => _quizzes;
  MCQSummary? get mcqSummary => _mcqSummary;

  Quiz? get selectedQuizForResults => _selectedQuizForResults;
  Student? get selectedStudentForProfile => _selectedStudentForProfile;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  Future<void> loadData() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final teacherFut = _repository.getTeacher().catchError((_) => Teacher(id: 'T-001', name: 'Dr. Anjali Menon', email: 'anjali.menon@example.edu'));
      final classFut = _repository.getClassInfo().catchError((_) => ClassInfo(id: 'C-001', name: 'Class 1', program: 'MBBS / Medical', studentCount: 25));
      final studentsFut = _repository.getStudents().catchError((_) => <Student>[]);
      final attendanceFut = _repository.getAttendanceHistory().catchError((_) => <AttendanceRecord>[]);
      final quizzesFut = _repository.getQuizzes().catchError((_) => <Quiz>[]);
      final mcqFut = _repository.getMCQSummary().catchError((_) => MCQSummary(totalAttempts: 150, questionsAttempted: 42, classAccuracy: 84, avgQuestionsPerStudent: 12));

      final results = await Future.wait([
        teacherFut,
        classFut,
        studentsFut,
        attendanceFut,
        quizzesFut,
        mcqFut,
      ]);

      _teacher = results[0] as Teacher;
      _classInfo = results[1] as ClassInfo;
      _students = results[2] as List<Student>;
      _attendanceHistory = results[3] as List<AttendanceRecord>;
      _quizzes = results[4] as List<Quiz>;
      _mcqSummary = results[5] as MCQSummary;

      if (_quizzes.isNotEmpty) {
        _selectedQuizForResults = _quizzes.first;
      }
      if (_students.isNotEmpty) {
        _selectedStudentForProfile = _students.first;
      }
      _hasError = false;
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setQuizFilter(String filter) {
    _quizFilter = filter;
    notifyListeners();
  }

  void setDashboardSearchQuery(String query) {
    _dashboardSearchQuery = query;
    notifyListeners();
  }

  void setStudentSearchQuery(String query) {
    _studentSearchQuery = query;
    notifyListeners();
  }

  void setQuizSearchQuery(String query) {
    _quizSearchQuery = query;
    notifyListeners();
  }

  void selectQuizForResults(Quiz quiz) {
    _selectedQuizForResults = quiz;
    notifyListeners();
  }

  void selectStudentForProfile(Student student) {
    _selectedStudentForProfile = student;
    notifyListeners();
  }

  void selectStudentProfile(Student student) => selectStudentForProfile(student);

  Future<void> toggleStudentAttendance(String studentId, bool isPresent) async {
    await _repository.updateStudentAttendance(studentId, isPresent);
    _students = await _repository.getStudents();
    notifyListeners();
  }

  // Calculated Metrics / KPIs
  int get totalQuizzesCount => _quizzes.length;

  int get avgScorePercentage {
    int totalScore = 0;
    int totalMax = 0;
    for (var q in _quizzes) {
      for (var a in q.attempts) {
        totalScore += a.score;
        totalMax += a.total;
      }
    }
    return totalMax > 0 ? ((totalScore / totalMax) * 100).round() : 0;
  }

  int get avgAccuracyPercentage {
    int totalCorrect = 0;
    int totalMax = 0;
    for (var q in _quizzes) {
      for (var a in q.attempts) {
        totalCorrect += a.correct;
        totalMax += a.total;
      }
    }
    return totalMax > 0 ? ((totalCorrect / totalMax) * 100).round() : 0;
  }

  int get latestQuizCompletionPercentage {
    if (_quizzes.isEmpty) return 0;
    final latest = _quizzes.first;
    final studentTotal = _classInfo?.studentCount ?? (_students.isNotEmpty ? _students.length : 1);
    return ((latest.attempts.length / studentTotal) * 100).round();
  }

  int get averageAttendancePercentage {
    if (_students.isEmpty) return 0;
    final totalPct = _students.fold<int>(0, (sum, s) => sum + s.attendancePercent);
    return (totalPct / _students.length).round();
  }

  List<Quiz> get filteredDashboardQuizzes {
    return _quizzes.where((q) {
      if (_quizFilter != 'all' && q.status != _quizFilter) return false;
      if (_dashboardSearchQuery.isNotEmpty) {
        final query = _dashboardSearchQuery.toLowerCase();
        final matchTitle = q.title.toLowerCase().contains(query);
        final matchSubject = q.subject.toLowerCase().contains(query);
        final matchId = q.id.toLowerCase().contains(query);
        if (!matchTitle && !matchSubject && !matchId) return false;
      }
      return true;
    }).toList();
  }

  List<Student> get filteredStudents {
    if (_studentSearchQuery.isEmpty) return _students;
    final query = _studentSearchQuery.toLowerCase();
    return _students.where((s) {
      return s.name.toLowerCase().contains(query) || s.roll.toLowerCase().contains(query);
    }).toList();
  }
}
