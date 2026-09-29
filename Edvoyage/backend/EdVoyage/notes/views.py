# api/views.py

import mimetypes

from django.http import FileResponse, Http404
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from .models import Subject, Doctor, Video, MCQ, Question, Option , ClinicalCase , Flashcard , FlashcardImage , Category
from rest_framework import serializers
from .serializers import SubjectSerializer, DoctorSerializer, VideoSerializer, MCQSerializer, QuestionSerializer, OptionSerializer , ClinicalCaseSerializer , FlashcardSerializer , CategorySerializer
from rest_framework import viewsets
from edvoayge.api_response import api_success, api_error

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all().order_by('id')
    serializer_class = CategorySerializer

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return api_success(data=serializer.data, message="Categories retrieved successfully")


class SubjectViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    """
    API endpoint that allows subjects to be viewed.
    Provides `list` and `retrieve` actions.
    """
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer

class DoctorViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
    """
    API endpoint that allows doctors to be viewed.
    Provides `list` and `retrieve` actions.
    """
    queryset = Doctor.objects.all()
    serializer_class = DoctorSerializer

class VideoViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None
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
    queryset = MCQ.objects.all()
    serializer_class = MCQSerializer


class QuestionViewSet(viewsets.ModelViewSet):
    pagination_class = None
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer


class OptionViewSet(viewsets.ModelViewSet):
    pagination_class = None
    queryset = Option.objects.all()
    serializer_class = OptionSerializer



class ClinicalCaseViewSet(viewsets.ModelViewSet):
    pagination_class = None
    # Use select_related to perform a SQL join and improve performance
    queryset = ClinicalCase.objects.select_related('doctor').all()
    serializer_class = ClinicalCaseSerializer


class FlashcardViewSet(viewsets.ReadOnlyModelViewSet):
    pagination_class = None

    queryset = Flashcard.objects.all().order_by('id')
    serializer_class = FlashcardSerializer


@api_view(['GET'])
@permission_classes([AllowAny])
def flashcard_image_file(request, pk):
    """Stream a flashcard image via the API (works when direct S3 URLs are private/missing)."""
    try:
        flashcard_image = FlashcardImage.objects.get(pk=pk)
    except FlashcardImage.DoesNotExist as exc:
        raise Http404("Flashcard image not found") from exc

    if not flashcard_image.image:
        raise Http404("Flashcard image file missing")

    content_type, _ = mimetypes.guess_type(flashcard_image.image.name)
    response = FileResponse(
        flashcard_image.image.open('rb'),
        content_type=content_type or 'image/jpeg',
    )
    response['Access-Control-Allow-Origin'] = '*'
    response['Cache-Control'] = 'public, max-age=86400'
    return response