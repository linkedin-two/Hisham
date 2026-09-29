from django.core.management.base import BaseCommand
from api.models import Teacher, ClassGroup, Student, AttendanceRecord, Quiz, QuizAttempt, QuestionResult, MCQSummary

class Command(BaseCommand):
    help = 'Seeds initial School Data into Django database'

    def handle(self, *args, **options):
        self.stdout.write('Seeding data...')

        # Clear existing
        Teacher.objects.all().delete()
        ClassGroup.objects.all().delete()
        Student.objects.all().delete()
        AttendanceRecord.objects.all().delete()
        Quiz.objects.all().delete()
        MCQSummary.objects.all().delete()

        # Seed Teacher & Class
        Teacher.objects.create(
            teacher_id="T-001",
            name="Dr. Anjali Menon",
            email="anjali.menon@example.edu"
        )

        ClassGroup.objects.create(
            class_id="CLASS-001",
            name="Class 1",
            program="Medical Entrance Program",
            student_count=42
        )

        # Seed Students
        students_data = [
            { "id": "ST-001", "name": "Aarav Menon", "roll": "ST-001", "attendancePercent": 96, "mcqAttempts": 428 },
            { "id": "ST-002", "name": "Ananya Raj", "roll": "ST-002", "attendancePercent": 98, "mcqAttempts": 402 },
            { "id": "ST-003", "name": "Diya Thomas", "roll": "ST-003", "attendancePercent": 95, "mcqAttempts": 388 },
            { "id": "ST-004", "name": "Arjun Kumar", "roll": "ST-004", "attendancePercent": 72, "mcqAttempts": 120 },
            { "id": "ST-005", "name": "Rahul Nair", "roll": "ST-005", "attendancePercent": 76, "mcqAttempts": 95 },
            { "id": "ST-006", "name": "Meera Joseph", "roll": "ST-006", "attendancePercent": 85, "mcqAttempts": 210 },
            { "id": "ST-007", "name": "Kavya Menon", "roll": "ST-007", "attendancePercent": 90, "mcqAttempts": 250 },
            { "id": "ST-008", "name": "Sameer Khan", "roll": "ST-008", "attendancePercent": 88, "mcqAttempts": 180 },
            { "id": "ST-009", "name": "Priya Singh", "roll": "ST-009", "attendancePercent": 92, "mcqAttempts": 305 },
            { "id": "ST-010", "name": "Ishaan Patel", "roll": "ST-010", "attendancePercent": 81, "mcqAttempts": 140 },
            { "id": "ST-011", "name": "Deepa Nair", "roll": "ST-011", "attendancePercent": 94, "mcqAttempts": 330 },
            { "id": "ST-012", "name": "Nitin Sharma", "roll": "ST-012", "attendancePercent": 78, "mcqAttempts": 110 }
        ]

        for s in students_data:
            Student.objects.create(
                student_id=s["id"],
                name=s["name"],
                roll=s["roll"],
                attendance_percent=s["attendancePercent"],
                mcq_attempts=s["mcqAttempts"]
            )

        # Seed Attendance History
        attendance_data = [
            { "date": "2026-07-20", "present": 38, "total": 42 },
            { "date": "2026-07-21", "present": 39, "total": 42 },
            { "date": "2026-07-22", "present": 40, "total": 42 },
            { "date": "2026-07-23", "present": 36, "total": 42 },
            { "date": "2026-07-24", "present": 38, "total": 42 }
        ]

        for a in attendance_data:
            AttendanceRecord.objects.create(
                date=a["date"],
                present=a["present"],
                total=a["total"]
            )

        # Seed Quizzes & Attempts
        q1 = Quiz.objects.create(
            quiz_id="QUIZ-018",
            title="Human Physiology",
            subject="Biology",
            question_count=25,
            status="completed",
            created="2026-07-20"
        )
        a1 = QuizAttempt.objects.create(
            quiz=q1, student_id="ST-001", score=23, total=25, correct=23, incorrect=2, accuracy=92, time_taken=1200
        )
        QuestionResult.objects.create(attempt=a1, question_id="Q-001", student_answer="A", correct_answer="A", is_correct=True)
        QuestionResult.objects.create(attempt=a1, question_id="Q-002", student_answer="C", correct_answer="C", is_correct=True)
        QuestionResult.objects.create(attempt=a1, question_id="Q-003", student_answer="B", correct_answer="C", is_correct=False)
        QuizAttempt.objects.create(
            quiz=q1, student_id="ST-002", score=24, total=25, correct=24, incorrect=1, accuracy=96, time_taken=1100
        )
        QuizAttempt.objects.create(
            quiz=q1, student_id="ST-004", score=14, total=25, correct=14, incorrect=11, accuracy=56, time_taken=1800
        )

        q2 = Quiz.objects.create(
            quiz_id="QUIZ-017",
            title="Organic Reactions",
            subject="Chemistry",
            question_count=30,
            status="in_progress",
            created="2026-07-15"
        )
        QuizAttempt.objects.create(quiz=q2, student_id="ST-001", score=22, total=30, correct=22, incorrect=8, accuracy=73)
        QuizAttempt.objects.create(quiz=q2, student_id="ST-002", score=26, total=30, correct=26, incorrect=4, accuracy=87)
        QuizAttempt.objects.create(quiz=q2, student_id="ST-005", score=19, total=30, correct=19, incorrect=11, accuracy=63)

        q3 = Quiz.objects.create(
            quiz_id="QUIZ-016",
            title="Mechanics",
            subject="Physics",
            question_count=20,
            status="completed",
            created="2026-07-10"
        )
        QuizAttempt.objects.create(quiz=q3, student_id="ST-003", score=18, total=20, correct=18, incorrect=2, accuracy=90)
        QuizAttempt.objects.create(quiz=q3, student_id="ST-009", score=19, total=20, correct=19, incorrect=1, accuracy=95)
        QuizAttempt.objects.create(quiz=q3, student_id="ST-010", score=15, total=20, correct=15, incorrect=5, accuracy=75)

        # Seed MCQ Summary
        MCQSummary.objects.create(
            total_attempts=1490,
            questions_attempted=4280,
            class_accuracy=82,
            avg_questions_per_student=102
        )

        self.stdout.write(self.style.SUCCESS('Successfully seeded Teacher CMS data!'))
