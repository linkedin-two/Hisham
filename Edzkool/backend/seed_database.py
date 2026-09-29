import os
import sys
import django
import random

# Initialize Django Settings
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'edvoayge.settings')
django.setup()

from django.contrib.auth import get_user_model
from teacher_cms.models import (
    Teacher, ClassGroup, Student, AttendanceRecord, Quiz, QuizAttempt, QuestionResult, MCQSummary
)
from universities.models import University, Feed
from notifications.models import Notification

User = get_user_model()

def seed_teacher_cms():
    print("Seeding Teacher CMS data...")
    
    # 1. Teacher Profile
    teacher, created = Teacher.objects.get_or_create(
        teacher_id="T-001",
        defaults={
            "name": "Dr. Anjali Menon",
            "email": "anjali.menon@example.edu"
        }
    )
    if not created:
        teacher.name = "Dr. Anjali Menon"
        teacher.email = "anjali.menon@example.edu"
        teacher.save()

    # 2. Class Group
    class_group, created = ClassGroup.objects.get_or_create(
        class_id="CLASS-001",
        defaults={
            "name": "Class 1",
            "program": "MBBS Medical Program",
            "student_count": 25
        }
    )

    # 3. Students
    student_names = [
        "Aarav Sharma", "Ananya Verma", "Rohan Gupta", "Priya Patel",
        "Rahul Nair", "Meera Iyer", "Karan Singh", "Siddharth Rao",
        "Kavya Joshi", "Vikram Reddy", "Ishita Banerjee", "Aditya Deshmukh",
        "Neha Kulkarni", "Devansh Malhotra", "Pooja Hegde", "Arjun Kapoor",
        "Riya Sen", "Tarun Kumar", "Shruti Mishra", "Manish Pandey",
        "Deepika Padukone", "Ranbir Roy", "Alia Bhatt", "Varun Dhawan", "Sara Ali"
    ]

    students = []
    for idx, name in enumerate(student_names, start=1):
        s_id = f"S-{idx:03d}"
        roll = f"MED-2024-{idx:03d}"
        att_pct = random.randint(78, 98)
        mcq_cnt = random.randint(25, 95)
        
        std, _ = Student.objects.update_or_create(
            student_id=s_id,
            defaults={
                "name": name,
                "roll": roll,
                "attendance_percent": att_pct,
                "mcq_attempts": mcq_cnt
            }
        )
        students.append(std)

    # 4. Attendance Records
    dates = [
        "2026-08-01", "2026-08-02", "2026-08-03", "2026-08-04", "2026-08-05",
        "2026-08-06", "2026-08-07", "2026-08-08", "2026-08-09", "2026-08-10"
    ]
    for d in dates:
        present_cnt = random.randint(21, 25)
        AttendanceRecord.objects.update_or_create(
            date=d,
            defaults={"present": present_cnt, "total": 25}
        )

    # 5. Quizzes & Attempts
    quizzes_data = [
        ("QZ-101", "Anatomy & Histology Drill", "Anatomy", 25, "completed", "2026-08-01"),
        ("QZ-102", "Pathology & Clinical Vignettes", "Pathology", 30, "in_progress", "2026-08-04"),
        ("QZ-103", "Pharmacology Rapid Fire", "Pharmacology", 20, "completed", "2026-08-06"),
        ("QZ-104", "Forensic Medicine Quiz", "Forensic", 15, "in_progress", "2026-08-08"),
        ("QZ-105", "General Surgery Spotters", "Surgery", 25, "in_progress", "2026-08-10"),
    ]

    for q_id, title, subj, q_cnt, status, dt in quizzes_data:
        quiz, _ = Quiz.objects.update_or_create(
            quiz_id=q_id,
            defaults={
                "title": title,
                "subject": subj,
                "question_count": q_cnt,
                "status": status,
                "created": dt
            }
        )
        
        # Add sample attempts for first 5 students
        for std in students[:5]:
            score = random.randint(15, q_cnt)
            correct = score
            incorrect = q_cnt - score
            accuracy = int((correct / q_cnt) * 100)
            
            attempt, _ = QuizAttempt.objects.update_or_create(
                quiz=quiz,
                student_id=std.student_id,
                defaults={
                    "score": score,
                    "total": q_cnt,
                    "correct": correct,
                    "incorrect": incorrect,
                    "accuracy": accuracy,
                    "time_taken": random.randint(12, 28)
                }
            )

    # 6. MCQ Summary
    MCQSummary.objects.update_or_create(
        id=1,
        defaults={
            "total_attempts": 1490,
            "questions_attempted": 4280,
            "class_accuracy": 82,
            "avg_questions_per_student": 102
        }
    )
    print("[SUCCESS] Teacher CMS successfully seeded!")

def seed_universities():
    print("Seeding Universities data...")
    univs_data = [
        {
            "name": "Kazan Federal University",
            "short_name": "KFU",
            "slug": "kazan-federal-university",
            "description": "One of the oldest and most prestigious universities in Russia, renowned for General Medicine (MBBS).",
            "university_type": "medical",
            "founded_year": 1804,
            "country": "Russia",
            "state": "Tatarstan",
            "city": "Kazan",
            "website": "https://kpfu.ru",
            "email": "admissions@kpfu.ru",
            "phone": "+7 843 233 7109",
            "total_students": 45000,
            "international_students": 11000,
            "faculty_count": 3000,
            "is_active": True,
            "is_featured": True,
            "is_verified": True
        },
        {
            "name": "Sechenov First Moscow State Medical University",
            "short_name": "Sechenov",
            "slug": "sechenov-university",
            "description": "The premier medical university in Russia offering top-tier clinical training and research facilities.",
            "university_type": "medical",
            "founded_year": 1758,
            "country": "Russia",
            "state": "Moscow",
            "city": "Moscow",
            "website": "https://sechenov.ru",
            "email": "admission@sechenov.ru",
            "phone": "+7 495 609 1400",
            "total_students": 19000,
            "international_students": 4000,
            "faculty_count": 2500,
            "is_active": True,
            "is_featured": True,
            "is_verified": True
        },
        {
            "name": "Saint Petersburg State University",
            "short_name": "SPbSU",
            "slug": "spbsu",
            "description": "Leading global university offering WHO and NMC recognized medical programs.",
            "university_type": "research",
            "founded_year": 1724,
            "country": "Russia",
            "state": "Saint Petersburg",
            "city": "Saint Petersburg",
            "website": "https://spbu.ru",
            "email": "english@spbu.ru",
            "phone": "+7 812 328 2000",
            "total_students": 30000,
            "international_students": 5000,
            "faculty_count": 4000,
            "is_active": True,
            "is_featured": True,
            "is_verified": True
        },
        {
            "name": "Tbilisi State Medical University",
            "short_name": "TSMU",
            "slug": "tsmu-georgia",
            "description": "Top choice in Georgia for international medical students, fully European accredited.",
            "university_type": "medical",
            "founded_year": 1918,
            "country": "Georgia",
            "state": "Tbilisi",
            "city": "Tbilisi",
            "website": "https://tsmu.edu",
            "email": "contact@tsmu.edu",
            "phone": "+995 32 254 2424",
            "total_students": 8000,
            "international_students": 2500,
            "faculty_count": 900,
            "is_active": True,
            "is_featured": True,
            "is_verified": True
        }
    ]

    for u in univs_data:
        univ, created = University.objects.update_or_create(
            slug=u["slug"],
            defaults=u
        )
        # Create feed posts
        Feed.objects.get_or_create(
            university=univ,
            title=f"Admissions Open for {univ.short_name} Batch 2026",
            defaults={
                "user_name": "Admission Office",
                "description": f"Applications for international medical aspirants are now open at {univ.name}. Apply before the deadline."
            }
        )
    print("[SUCCESS] Universities successfully seeded!")

def seed_notifications():
    print("Seeding Notifications...")
    notifs = [
        {"title": "Welcome to EdVoyage Medical Platform", "description": "Your profile has been created successfully. Explore universities & notes.", "subtitle": "Get Started", "is_offer": False},
        {"title": "FMGE / NEXT Exam Registration Reminder", "description": "Remember to submit your credentials before the upcoming deadline.", "subtitle": "Exam Alert", "is_offer": False},
        {"title": "New Video Lecture Series Released", "description": "High-yield Pharmacology & Pathology video lectures are now available in Clinical Notes.", "subtitle": "New Content", "is_offer": True},
        {"title": "Exclusive Medical Scholarship Offer", "description": "Get up to 20% tuition fee grant for top European medical universities.", "subtitle": "Special Offer", "is_offer": True},
    ]
    for n in notifs:
        Notification.objects.get_or_create(
            title=n["title"],
            defaults={
                "description": n["description"],
                "subtitle": n["subtitle"],
                "is_offer": n["is_offer"]
            }
        )
    print("[SUCCESS] Notifications successfully seeded!")

if __name__ == '__main__':
    print("--- Starting Backend Database Seeding ---")
    seed_teacher_cms()
    seed_universities()
    seed_notifications()
    print("[ALL SUCCESS] All backend data seeded successfully!")
