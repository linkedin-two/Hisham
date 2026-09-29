# api/views.py

from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from .models import Subject, Doctor, Video, MCQ, Question, Option , ClinicalCase , Flashcard , FlashcardImage , Category
from rest_framework import serializers
from .serializers import SubjectSerializer, DoctorSerializer, VideoSerializer, MCQSerializer, QuestionSerializer, OptionSerializer , ClinicalCaseSerializer , FlashcardSerializer , CategorySerializer
from rest_framework import viewsets
from edvoayge.api_response import api_success, api_error

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all().order_by('id')
    serializer_class = CategorySerializer
    permission_classes = [IsAuthenticatedOrReadOnly]

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return api_success(data=serializer.data, message="Categories retrieved successfully")


class SubjectViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    """
    API endpoint that allows subjects to be viewed.
    Provides `list` and `retrieve` actions.
    """
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer

class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    """
    API endpoint that allows doctors to be viewed.
    Provides `list` and `retrieve` actions.
    """
    queryset = Doctor.objects.all()
    serializer_class = DoctorSerializer

class VideoViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    """
    API endpoint that allows videos to be viewed.
    Provides `list` and `retrieve` actions.
    Can be filtered by subject or doctor ID, e.g., /api/videos/?subject=1
    """
    queryset = Video.objects.all()
    serializer_class = VideoSerializer
    filterset_fields = ['subject', 'doctor', 'is_free', 'category']


class MCQViewSet(viewsets.ModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = MCQ.objects.all()
    serializer_class = MCQSerializer


class QuestionViewSet(viewsets.ModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer


class OptionViewSet(viewsets.ModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    queryset = Option.objects.all()
    serializer_class = OptionSerializer



class ClinicalCaseViewSet(viewsets.ModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]
    # Use select_related to perform a SQL join and improve performance
    queryset = ClinicalCase.objects.select_related('doctor').all()
    serializer_class = ClinicalCaseSerializer


class FlashcardViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    permission_classes = [IsAuthenticatedOrReadOnly]

    queryset = Flashcard.objects.all().order_by('id')
    serializer_class = FlashcardSerializer