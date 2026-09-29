library;

/// Strong typed data models for Teacher CMS.

/// Designed for easy JSON serialization when connecting a real backend/database later.

class Teacher {
  final String id;
  final String name;
  final String email;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}

class ClassInfo {
  final String id;
  final String name;
  final String program;
  final int studentCount;

  ClassInfo({
    required this.id,
    required this.name,
    required this.program,
    required this.studentCount,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        program: json['program'] ?? '',
        studentCount: json['studentCount'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'program': program,
        'studentCount': studentCount,
      };
}

class Student {
  final String id;
  final String name;
  final String roll;
  int attendancePercent;
  final int mcqAttempts;
  bool? isPresent; // Transient session state for marking attendance

  Student({
    required this.id,
    required this.name,
    required this.roll,
    required this.attendancePercent,
    required this.mcqAttempts,
    this.isPresent,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        roll: json['roll'] ?? '',
        attendancePercent: json['attendancePercent'] ?? 0,
        mcqAttempts: json['mcqAttempts'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'roll': roll,
        'attendancePercent': attendancePercent,
        'mcqAttempts': mcqAttempts,
      };

  Student copyWith({
    String? id,
    String? name,
    String? roll,
    int? attendancePercent,
    int? mcqAttempts,
    bool? isPresent,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      roll: roll ?? this.roll,
      attendancePercent: attendancePercent ?? this.attendancePercent,
      mcqAttempts: mcqAttempts ?? this.mcqAttempts,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

class AttendanceRecord {
  final String date;
  final int present;
  final int total;

  AttendanceRecord({
    required this.date,
    required this.present,
    required this.total,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        date: json['date'] ?? '',
        present: json['present'] ?? 0,
        total: json['total'] ?? 0,
      );
}

class QuestionResult {
  final String questionId;
  final String studentAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.questionId,
    required this.studentAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) => QuestionResult(
        questionId: json['questionId'] ?? '',
        studentAnswer: json['studentAnswer'] ?? '',
        correctAnswer: json['correctAnswer'] ?? '',
        isCorrect: json['isCorrect'] ?? false,
      );
}

class QuizAttempt {
  final String studentId;
  final int score;
  final int total;
  final int correct;
  final int incorrect;
  final int accuracy;
  final int? timeTaken;
  final List<QuestionResult>? questionResults;

  QuizAttempt({
    required this.studentId,
    required this.score,
    required this.total,
    required this.correct,
    required this.incorrect,
    required this.accuracy,
    this.timeTaken,
    this.questionResults,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        studentId: json['studentId'] ?? '',
        score: json['score'] ?? 0,
        total: json['total'] ?? 0,
        correct: json['correct'] ?? 0,
        incorrect: json['incorrect'] ?? 0,
        accuracy: json['accuracy'] ?? 0,
        timeTaken: json['timeTaken'],
        questionResults: json['questionResults'] != null
            ? (json['questionResults'] as List)
                .map((x) => QuestionResult.fromJson(x))
                .toList()
            : null,
      );
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final int questionCount;
  final String status;
  final String created;
  final List<QuizAttempt> attempts;

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.questionCount,
    required this.status,
    required this.created,
    required this.attempts,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        subject: json['subject'] ?? '',
        questionCount: json['questionCount'] ?? 0,
        status: json['status'] ?? 'in_progress',
        created: json['created'] ?? '',
        attempts: json['attempts'] != null
            ? (json['attempts'] as List)
                .map((x) => QuizAttempt.fromJson(x))
                .toList()
            : [],
      );
}

class MCQSummary {
  final int totalAttempts;
  final int questionsAttempted;
  final int classAccuracy;
  final int avgQuestionsPerStudent;

  MCQSummary({
    required this.totalAttempts,
    required this.questionsAttempted,
    required this.classAccuracy,
    required this.avgQuestionsPerStudent,
  });

  factory MCQSummary.fromJson(Map<String, dynamic> json) => MCQSummary(
        totalAttempts: json['totalAttempts'] ?? 0,
        questionsAttempted: json['questionsAttempted'] ?? 0,
        classAccuracy: json['classAccuracy'] ?? 0,
        avgQuestionsPerStudent: json['avgQuestionsPerStudent'] ?? 0,
      );
}
