from django.db import models

class Teacher(models.Model):
    teacher_id = models.CharField(max_length=50, unique=True, default="T-001")
    name = models.CharField(max_length=150, default="Dr. Anjali Menon")
    email = models.EmailField(default="anjali.menon@example.edu")

    def __str__(self):
        return f"{self.name} ({self.teacher_id})"

class ClassGroup(models.Model):
    class_id = models.CharField(max_length=50, unique=True, default="CLASS-001")
    name = models.CharField(max_length=100, default="Class 1")
    program = models.CharField(max_length=200, default="Medical Entrance Program")
    student_count = models.IntegerField(default=42)

    def __str__(self):
        return f"{self.name} - {self.program}"

class Student(models.Model):
    student_id = models.CharField(max_length=50, unique=True)
    name = models.CharField(max_length=150)
    roll = models.CharField(max_length=50)
    attendance_percent = models.IntegerField(default=90)
    mcq_attempts = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.name} ({self.roll})"

class AttendanceRecord(models.Model):
    date = models.CharField(max_length=50)
    present = models.IntegerField(default=0)
    total = models.IntegerField(default=42)

    def __str__(self):
        return f"{self.date}: {self.present}/{self.total}"

class Quiz(models.Model):
    quiz_id = models.CharField(max_length=50, unique=True)
    title = models.CharField(max_length=200)
    subject = models.CharField(max_length=100)
    question_count = models.IntegerField(default=25)
    status = models.CharField(max_length=50, default="in_progress")
    created = models.CharField(max_length=50, default="2026-07-20")

    def __str__(self):
        return f"{self.subject} - {self.title} ({self.quiz_id})"

class QuizAttempt(models.Model):
    quiz = models.ForeignKey(Quiz, related_name='attempts', on_delete=models.CASCADE)
    student_id = models.CharField(max_length=50)
    score = models.IntegerField(default=0)
    total = models.IntegerField(default=0)
    correct = models.IntegerField(default=0)
    incorrect = models.IntegerField(default=0)
    accuracy = models.IntegerField(default=0)
    time_taken = models.IntegerField(null=True, blank=True)

    def __str__(self):
        return f"{self.quiz.quiz_id} attempt by {self.student_id}"

class QuestionResult(models.Model):
    attempt = models.ForeignKey(QuizAttempt, related_name='question_results', on_delete=models.CASCADE)
    question_id = models.CharField(max_length=50)
    student_answer = models.CharField(max_length=10)
    correct_answer = models.CharField(max_length=10)
    is_correct = models.BooleanField(default=False)

class MCQSummary(models.Model):
    total_attempts = models.IntegerField(default=1490)
    questions_attempted = models.IntegerField(default=4280)
    class_accuracy = models.IntegerField(default=82)
    avg_questions_per_student = models.IntegerField(default=102)
