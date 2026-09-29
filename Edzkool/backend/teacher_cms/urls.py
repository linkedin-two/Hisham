from django.urls import path
from .views import (
    TeacherProfileView,
    ClassInfoView,
    StudentListView,
    AttendanceRecordListView,
    QuizListView,
    MCQSummaryView,
    UpdateAttendanceView,
)

urlpatterns = [
    path('', TeacherProfileView.as_view(), name='teacher-profile-root'),
    path('teacher/', TeacherProfileView.as_view(), name='teacher-profile'),
    path('class/', ClassInfoView.as_view(), name='class-info'),
    path('students/', StudentListView.as_view(), name='student-list'),
    path('attendance/', AttendanceRecordListView.as_view(), name='attendance-list'),
    path('attendance/update/', UpdateAttendanceView.as_view(), name='attendance-update'),
    path('quizzes/', QuizListView.as_view(), name='quiz-list'),
    path('mcq-summary/', MCQSummaryView.as_view(), name='mcq-summary'),
]
