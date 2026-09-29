from rest_framework import serializers
from .models import Teacher, ClassGroup, Student, AttendanceRecord, Quiz, QuizAttempt, QuestionResult, MCQSummary

class TeacherSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='teacher_id')
    
    class Meta:
        model = Teacher
        fields = ['id', 'name', 'email']

class ClassGroupSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='class_id')
    studentCount = serializers.IntegerField(source='student_count')

    class Meta:
        model = ClassGroup
        fields = ['id', 'name', 'program', 'studentCount']

class StudentSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='student_id')
    attendancePercent = serializers.IntegerField(source='attendance_percent')
    mcqAttempts = serializers.IntegerField(source='mcq_attempts')

    class Meta:
        model = Student
        fields = ['id', 'name', 'roll', 'attendancePercent', 'mcqAttempts']

class AttendanceRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = AttendanceRecord
        fields = ['date', 'present', 'total']

class QuestionResultSerializer(serializers.ModelSerializer):
    questionId = serializers.CharField(source='question_id')
    studentAnswer = serializers.CharField(source='student_answer')
    correctAnswer = serializers.CharField(source='correct_answer')
    isCorrect = serializers.BooleanField(source='is_correct')

    class Meta:
        model = QuestionResult
        fields = ['questionId', 'studentAnswer', 'correctAnswer', 'isCorrect']

class QuizAttemptSerializer(serializers.ModelSerializer):
    studentId = serializers.CharField(source='student_id')
    timeTaken = serializers.IntegerField(source='time_taken', required=False, allow_null=True)
    questionResults = QuestionResultSerializer(source='question_results', many=True, read_only=True)

    class Meta:
        model = QuizAttempt
        fields = ['studentId', 'score', 'total', 'correct', 'incorrect', 'accuracy', 'timeTaken', 'questionResults']

class QuizSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='quiz_id')
    questionCount = serializers.IntegerField(source='question_count')
    attempts = QuizAttemptSerializer(many=True, read_only=True)

    class Meta:
        model = Quiz
        fields = ['id', 'title', 'subject', 'questionCount', 'status', 'created', 'attempts']

class MCQSummarySerializer(serializers.ModelSerializer):
    totalAttempts = serializers.IntegerField(source='total_attempts')
    questionsAttempted = serializers.IntegerField(source='questions_attempted')
    classAccuracy = serializers.IntegerField(source='class_accuracy')
    avgQuestionsPerStudent = serializers.IntegerField(source='avg_questions_per_student')

    class Meta:
        model = MCQSummary
        fields = ['totalAttempts', 'questionsAttempted', 'classAccuracy', 'avgQuestionsPerStudent']
