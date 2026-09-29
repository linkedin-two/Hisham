from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .models import Teacher, ClassGroup, Student, AttendanceRecord, Quiz, MCQSummary
from .serializers import (
    TeacherSerializer,
    ClassGroupSerializer,
    StudentSerializer,
    AttendanceRecordSerializer,
    QuizSerializer,
    MCQSummarySerializer,
)

class TeacherProfileView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        teacher = Teacher.objects.first()
        if not teacher:
            teacher = Teacher.objects.create(
                teacher_id="T-001",
                name="Dr. Anjali Menon",
                email="anjali.menon@example.edu"
            )
        serializer = TeacherSerializer(teacher)
        return Response(serializer.data)

class ClassInfoView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        class_obj = ClassGroup.objects.first()
        if not class_obj:
            class_obj = ClassGroup.objects.create(
                class_id="CLASS-001",
                name="Class 1",
                program="Medical Entrance Program",
                student_count=42
            )
        serializer = ClassGroupSerializer(class_obj)
        return Response(serializer.data)

class StudentListView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        students = Student.objects.all()
        serializer = StudentSerializer(students, many=True)
        return Response(serializer.data)

class AttendanceRecordListView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        records = AttendanceRecord.objects.all()
        serializer = AttendanceRecordSerializer(records, many=True)
        return Response(serializer.data)

class QuizListView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        quizzes = Quiz.objects.all()
        serializer = QuizSerializer(quizzes, many=True)
        return Response(serializer.data)

class MCQSummaryView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        summary = MCQSummary.objects.first()
        if not summary:
            summary = MCQSummary.objects.create()
        serializer = MCQSummarySerializer(summary)
        return Response(serializer.data)

class UpdateAttendanceView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        student_id = request.data.get('studentId')
        is_present = request.data.get('isPresent')
        if not student_id:
            return Response({'error': 'studentId is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            student = Student.objects.get(student_id=student_id)
            if is_present:
                student.attendance_percent = min(100, student.attendance_percent + 1)
            else:
                student.attendance_percent = max(0, student.attendance_percent - 1)
            student.save()
            return Response({'status': 'updated', 'attendancePercent': student.attendance_percent})
        except Student.DoesNotExist:
            return Response({'error': 'Student not found'}, status=status.HTTP_404_NOT_FOUND)
