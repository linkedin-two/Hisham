"""
Application views for EdVoyage API.
Handles application-related API endpoints with proper error handling and logging.
"""

import logging
from django.shortcuts import get_object_or_404
from django.db.models import Q, Count, Avg, Min, Max
from django.utils import timezone
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.pagination import PageNumberPagination
from django_filters.rest_framework import DjangoFilterBackend
from edvoayge.api_response import api_success, api_error
from .models import (
    Application, ApplicationDocument, ApplicationStatus, ApplicationInterview,
    ApplicationFee, ApplicationCommunication
)
from .serializers import (
    ApplicationSerializer, ApplicationCreateSerializer, ApplicationUpdateSerializer,
    ApplicationDocumentSerializer, ApplicationDocumentCreateSerializer,
    ApplicationStatusSerializer, ApplicationStatusUpdateSerializer,
    ApplicationInterviewSerializer, ApplicationInterviewCreateSerializer,
    ApplicationFeeSerializer, ApplicationFeeCreateSerializer,
    ApplicationCommunicationSerializer, ApplicationSubmitSerializer,
    ApplicationSearchSerializer, ApplicationStatsSerializer, ApplicationDashboardSerializer,
    FrontendApplicationSerializer
)

logger = logging.getLogger(__name__)


class ApplicationPagination(PageNumberPagination):
    """Custom pagination for application listings."""
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class ApplicationViewSet(viewsets.ModelViewSet):
    """
    ViewSet for application management.
    Provides CRUD operations for applications with search and filtering.
    """
    serializer_class = ApplicationSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = [
        'status', 'priority', 'university', 'program', 'is_complete', 
        'is_verified', 'intended_start_semester', 'academic_year'
    ]
    search_fields = [
        'application_number', 'personal_statement', 'research_proposal',
        'university__name', 'program__name'
    ]
    ordering_fields = [
        'created_at', 'submitted_at', 'decision_date', 'priority', 'status'
    ]
    ordering = ['-created_at']

    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """Filter applications by current user; staff see all."""
        qs = Application.objects.all().select_related(
            'university', 'program'
        ).prefetch_related(
            'documents', 'status_history', 'interviews', 'fees', 'communications'
        )
        if self.request.user.is_staff:
            return qs
        return qs.filter(user=self.request.user)

    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'list':
            return FrontendApplicationSerializer
        elif self.action == 'create':
            return ApplicationCreateSerializer
        elif self.action in ['update', 'partial_update']:
            return ApplicationUpdateSerializer
        return ApplicationSerializer

    def list(self, request, *args, **kwargs):
        """List applications with enhanced filtering."""
        
        try:
            response = super().list(request, *args, **kwargs)
            return response
        except Exception as e:
            logger.error(f"Error in application list: {e}")
            return api_error(
                message='Error retrieving applications',
                error_code='application_list_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def create(self, request, *args, **kwargs):
        """Create a new application."""
        try:
            response = super().create(request, *args, **kwargs)
            return api_success(
                data=response.data, 
                message='Application created successfully',
                status_code=status.HTTP_201_CREATED
            )
        except Exception as e:
            logger.error(f"Error creating application: {e}")
            return api_error(
                message='Error creating application',
                error_code='application_create_error',
                status_code=status.HTTP_400_BAD_REQUEST
            )

    @action(detail=False, methods=['post'], url_path='submit')
    def submit(self, request, pk=None):
        """Submit an application."""
        try:
            application = self.get_object()
            
            # Check if application can be submitted
            if application.status != 'draft':
                return api_error(
                    message='Application can only be submitted from draft status',
                    error_code='invalid_application_status',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Validate required documents
            required_documents = application.documents.filter(is_required=True)
            if not required_documents.exists():
                return api_error(
                    message='Please upload all required documents before submitting',
                    error_code='missing_required_documents',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Update application status
            application.status = 'submitted'
            application.submitted_at = timezone.now()
            application.save()
            
            # Create status history
            ApplicationStatus.objects.create(
                application=application,
                status='submitted',
                description='Application submitted successfully',
                changed_by=request.user
            )
            
            return api_success(
                data=None,
                message='Application submitted successfully'
            )
        except Exception as e:
            logger.error(f"Error submitting application: {e}")
            return api_error(
                message='Error submitting application',
                error_code='application_submit_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['post'], url_path='search')
    def search(self, request):
        """Advanced application search."""
        try:
            serializer = ApplicationSearchSerializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            
            queryset = self.get_queryset()
            
            # Apply search filters
            status = serializer.validated_data.get('status')
            if status:
                queryset = queryset.filter(status=status)
            
            priority = serializer.validated_data.get('priority')
            if priority:
                queryset = queryset.filter(priority=priority)
            
            university = serializer.validated_data.get('university')
            if university:
                queryset = queryset.filter(university_id=university)
            
            program = serializer.validated_data.get('program')
            if program:
                queryset = queryset.filter(program_id=program)
            
            is_complete = serializer.validated_data.get('is_complete')
            if is_complete is not None:
                queryset = queryset.filter(is_complete=is_complete)
            
            is_verified = serializer.validated_data.get('is_verified')
            if is_verified is not None:
                queryset = queryset.filter(is_verified=is_verified)
            
            date_from = serializer.validated_data.get('date_from')
            if date_from:
                queryset = queryset.filter(created_at__date__gte=date_from)
            
            date_to = serializer.validated_data.get('date_to')
            if date_to:
                queryset = queryset.filter(created_at__date__lte=date_to)
            
            # Paginate results
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = ApplicationSerializer(page, many=True)
                return self.get_paginated_response(serializer.data)
            
            serializer = ApplicationSerializer(queryset, many=True)
            return api_success(
                data={
                    'data': serializer.data,
                    'count': len(serializer.data)
                },
                message=f'Found {len(serializer.data)} applications'
            )
        except Exception as e:
            logger.error(f"Error in application search: {e}")
            return api_error(
                message='Error searching applications',
                error_code='application_search_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'], url_path='stats')
    def stats(self, request):
        """Get application statistics."""
        try:
            queryset = self.get_queryset()
            
            # Calculate statistics
            total_applications = queryset.count()
            submitted_applications = queryset.filter(status='submitted').count()
            accepted_applications = queryset.filter(status='accepted').count()
            rejected_applications = queryset.filter(status='rejected').count()
            pending_applications = queryset.filter(status__in=['draft', 'under_review']).count()
            
            # Applications by status
            applications_by_status = queryset.values('status').annotate(
                count=Count('id')
            ).order_by('-count')
            
            # Applications by university
            applications_by_university = queryset.values('university__name').annotate(
                count=Count('id')
            ).order_by('-count')
            
            # Recent applications
            recent_applications = queryset.order_by('-created_at')[:10]
            
            # Overdue applications
            overdue_applications = queryset.filter(
                status__in=['submitted', 'under_review'],
                submitted_at__lt=timezone.now() - timezone.timedelta(days=30)
            )
            
            data = {
                'total_applications': total_applications,
                'submitted_applications': submitted_applications,
                'accepted_applications': accepted_applications,
                'rejected_applications': rejected_applications,
                'pending_applications': pending_applications,
                'applications_by_status': {item['status']: item['count'] for item in applications_by_status},
                'applications_by_university': {item['university__name']: item['count'] for item in applications_by_university},
                'recent_applications': ApplicationSerializer(recent_applications, many=True).data,
                'overdue_applications': ApplicationSerializer(overdue_applications, many=True).data,
            }
            
            return api_success(
                data=data, 
                message='Statistics retrieved successfully'
            )
        except Exception as e:
            logger.error(f"Error in application stats: {e}")
            return api_error(
                message='Error retrieving statistics',
                error_code='application_stats_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=False, methods=['get'], url_path='dashboard')
    def dashboard(self, request):
        """Get application dashboard data."""
        try:
            queryset = self.get_queryset() if hasattr(self, 'get_queryset') else Application.objects.all()
            # Dashboard data (no user filtering)
            user_applications = queryset.order_by('-created_at')[:5]
            recent_status_updates = ApplicationStatus.objects.order_by('-changed_at')[:10]
            upcoming_interviews = ApplicationInterview.objects.filter(status='scheduled', scheduled_date__gte=timezone.now()).order_by('scheduled_date')[:5]
            pending_fees = ApplicationFee.objects.filter(payment_status='pending').order_by('due_date')[:5]
            recent_communications = ApplicationCommunication.objects.order_by('-created_at')[:10]
            # Calculate stats
            stats_data = {
                'total_applications': queryset.count(),
                'submitted_applications': queryset.filter(status='submitted').count(),
                'accepted_applications': queryset.filter(status='accepted').count(),
                'rejected_applications': queryset.filter(status='rejected').count(),
                'pending_applications': queryset.filter(status__in=['draft', 'under_review']).count(),
                'applications_by_status': {},
                'applications_by_university': {},
                'recent_applications': ApplicationSerializer(user_applications, many=True).data,
                'overdue_applications': [],
            }
            data = {
                'user_applications': ApplicationSerializer(user_applications, many=True).data,
                'recent_status_updates': ApplicationStatusSerializer(recent_status_updates, many=True).data,
                'upcoming_interviews': ApplicationInterviewSerializer(upcoming_interviews, many=True).data,
                'pending_fees': ApplicationFeeSerializer(pending_fees, many=True).data,
                'recent_communications': ApplicationCommunicationSerializer(recent_communications, many=True).data,
                'application_stats': stats_data,
            }
            return api_success(
                data=data, 
                message='Dashboard data retrieved successfully'
            )
        except Exception as e:
            import traceback
            logger.error(f"Error in application dashboard: {e}")
            return api_error(
                message='Error retrieving dashboard data',
                error_code='application_dashboard_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ApplicationDocumentViewSet(viewsets.ModelViewSet):
    """ViewSet for application document management."""
    serializer_class = ApplicationDocumentSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['document_type', 'status', 'is_required', 'is_verified']
    search_fields = ['document_name', 'document_type']
    ordering = ['-uploaded_at']

    def get_queryset(self):
        """Filter documents by current user's applications."""
        return ApplicationDocument.objects.filter(
            application__user=self.request.user
        ).select_related('application')

    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'create':
            return ApplicationDocumentCreateSerializer
        return ApplicationDocumentSerializer

    def perform_create(self, serializer):
        """Create document with application context."""
        application_id = self.kwargs.get('application_pk')
        application = get_object_or_404(Application, id=application_id, user=self.request.user)
        serializer.save(application=application)

    def list(self, request, *args, **kwargs):
        """List documents with enhanced filtering."""
        try:
            response = super().list(request, *args, **kwargs)
            return response
        except Exception as e:
            logger.error(f"Error in document list: {e}")
            return Response(
                {'success': False, 'message': 'Error retrieving documents'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ApplicationStatusViewSet(viewsets.ModelViewSet):
    """ViewSet for application status management."""
    serializer_class = ApplicationStatusSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'changed_by']
    ordering = ['-changed_at']

    def get_queryset(self):
        """Filter status history by current user's applications."""
        return ApplicationStatus.objects.filter(
            application__user=self.request.user
        ).select_related('application', 'changed_by')

    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'create':
            return ApplicationStatusUpdateSerializer
        return ApplicationStatusSerializer

    def perform_create(self, serializer):
        """Create status update with application context."""
        application_id = self.kwargs.get('application_pk')
        application = get_object_or_404(Application, id=application_id, user=self.request.user)
        serializer.save(application=application)


class ApplicationInterviewViewSet(viewsets.ModelViewSet):
    """ViewSet for application interview management."""
    serializer_class = ApplicationInterviewSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['interview_type', 'status', 'interviewer_name']
    search_fields = ['interviewer_name', 'location', 'platform']
    ordering_fields = ['scheduled_date', 'created_at']
    ordering = ['-scheduled_date']

    def get_queryset(self):
        """Filter interviews by current user's applications."""
        return ApplicationInterview.objects.filter(
            application__user=self.request.user
        ).select_related('application')

    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'create':
            return ApplicationInterviewCreateSerializer
        return ApplicationInterviewSerializer

    def perform_create(self, serializer):
        """Create interview with application context."""
        application_id = self.kwargs.get('application_pk')
        application = get_object_or_404(Application, id=application_id, user=self.request.user)
        serializer.save(application=application)

    def list(self, request, *args, **kwargs):
        """List interviews with enhanced filtering."""
        try:
            response = super().list(request, *args, **kwargs)
            return response
        except Exception as e:
            logger.error(f"Error in interview list: {e}")
            return Response(
                {'success': False, 'message': 'Error retrieving interviews'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ApplicationFeeViewSet(viewsets.ModelViewSet):
    """ViewSet for application fee management."""
    serializer_class = ApplicationFeeSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['fee_type', 'payment_status', 'currency']
    ordering_fields = ['due_date', 'amount', 'created_at']
    ordering = ['-created_at']

    def get_queryset(self):
        """Filter fees by current user's applications."""
        return ApplicationFee.objects.filter(
            application__user=self.request.user
        ).select_related('application')

    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'create':
            return ApplicationFeeCreateSerializer
        return ApplicationFeeSerializer

    def perform_create(self, serializer):
        """Create fee with application context."""
        application_id = self.kwargs.get('application_pk')
        application = get_object_or_404(Application, id=application_id, user=self.request.user)
        serializer.save(application=application)

    def list(self, request, *args, **kwargs):
        """List fees with enhanced filtering."""
        try:
            response = super().list(request, *args, **kwargs)
            return response
        except Exception as e:
            logger.error(f"Error in fee list: {e}")
            return Response(
                {'success': False, 'message': 'Error retrieving fees'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ApplicationCommunicationViewSet(viewsets.ModelViewSet):
    """ViewSet for application communication management."""
    serializer_class = ApplicationCommunicationSerializer
    pagination_class = ApplicationPagination
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['communication_type', 'direction', 'is_sent', 'is_delivered', 'is_read']
    search_fields = ['subject', 'message', 'from_email', 'to_email']
    ordering = ['-created_at']

    def get_queryset(self):
        """Filter communications by current user's applications."""
        return ApplicationCommunication.objects.filter(
            application__user=self.request.user
        ).select_related('application')

    def list(self, request, *args, **kwargs):
        """List communications with enhanced filtering."""
        try:
            response = super().list(request, *args, **kwargs)
            return response
        except Exception as e:
            logger.error(f"Error in communication list: {e}")
            return Response(
                {'success': False, 'message': 'Error retrieving communications'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
