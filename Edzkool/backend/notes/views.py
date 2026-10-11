# api/views.py

from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from .models import Subject, Doctor, Video, MCQ, Question, Option , ClinicalCase , Flashcard , FlashcardImage , Category
from rest_framework import serializers
from .serializers import (
    SubjectSerializer, DoctorSerializer, VideoSerializer, MCQSerializer,
    QuestionSerializer, OptionSerializer, ClinicalCaseSerializer,
    FlashcardSerializer, FlashcardImageSerializer, CategorySerializer
)
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
    serializer_class = FlashcardSerializer

    def get_queryset(self):
        qs = Flashcard.objects.all().order_by('id')
        category_name = self.request.query_params.get('category_name')
        subject_name = self.request.query_params.get('subject_name')
        sub_subject_name = self.request.query_params.get('sub_subject_name')
        description = self.request.query_params.get('description')

        if category_name:
            qs = qs.filter(category__name__iexact=category_name)
        if subject_name:
            qs = qs.filter(subject__name__iexact=subject_name)
        if sub_subject_name:
            qs = qs.filter(sub_subject__name__iexact=sub_subject_name)
        if description:
            qs = qs.filter(description__icontains=description)

        return qs

    @action(detail=True, methods=['get'], url_path='images')
    def images(self, request, pk=None):
        """
        Paginated endpoint for lazy loading flashcard images in chunks (default 5).
        GET /notes/flashcards/{id}/images/?page=1&page_size=5
        """
        flashcard = self.get_object()
        try:
            page = max(1, int(request.query_params.get('page', 1)))
            page_size = max(1, min(100, int(request.query_params.get('page_size', 5))))
        except (ValueError, TypeError):
            page = 1
            page_size = 5

        total = flashcard.images.count()
        offset = (page - 1) * page_size
        images_page = flashcard.images.all()[offset:offset + page_size]

        serializer = FlashcardImageSerializer(images_page, many=True, context={'request': request})
        return api_success(
            data={
                'total_images': total,
                'page': page,
                'page_size': page_size,
                'has_next': (offset + page_size) < total,
                'results': serializer.data
            },
            message="Flashcard images retrieved"
        )