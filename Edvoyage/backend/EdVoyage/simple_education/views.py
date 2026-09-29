from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from django.contrib.auth import get_user_model
from django.db.models import Q
from edvoayge.api_response import api_success, api_error

from .models import SimpleEducation, SimpleWork, SimpleSocial
from .serializers import SimpleEducationSerializer, SimpleWorkSerializer, SimpleSocialSerializer


def _get_user_from_email(email: str):
    User = get_user_model()
    return User.objects.filter(Q(email__iexact=email) | Q(profile__email__iexact=email)).first()


def _resolve_user_from_request(request):
    email = (
        request.query_params.get('email')
        or request.data.get('email')
        or request.data.get('user_email')
        or ''
    )
    email = (email or '').strip()
    if not email:
        return None
    return _get_user_from_email(email)


class MyEducationView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        education = SimpleEducation.objects.filter(user=user).first()
        if not education:
            return api_error(
                message='No education record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND
            )
        serializer = SimpleEducationSerializer(education)
        return api_success(data=serializer.data, message='Education fetched successfully')


class UpdateEducationView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        education = SimpleEducation.objects.filter(user=user).first()
        if education:
            serializer = SimpleEducationSerializer(education, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return api_success(data=serializer.data, message='Education updated successfully')
            return api_error(
                message='Validation error',
                error_code='validation_error',
                details=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )

        serializer = SimpleEducationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return api_success(data=serializer.data, message='Education created successfully', status_code=status.HTTP_201_CREATED)
        return api_error(
            message='Validation error',
            error_code='validation_error',
            details=serializer.errors,
            status_code=status.HTTP_400_BAD_REQUEST
        )


class MyWorkView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        work = SimpleWork.objects.filter(user=user).first()
        if not work:
            return api_error(
                message='No work record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND
            )
        serializer = SimpleWorkSerializer(work)
        return api_success(data=serializer.data, message='Work fetched successfully')


class UpdateWorkView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        work = SimpleWork.objects.filter(user=user).first()
        if work:
            serializer = SimpleWorkSerializer(work, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return api_success(data=serializer.data, message='Work updated successfully')
            return api_error(
                message='Validation error',
                error_code='validation_error',
                details=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )

        serializer = SimpleWorkSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return api_success(data=serializer.data, message='Work created successfully', status_code=status.HTTP_201_CREATED)
        return api_error(
            message='Validation error',
            error_code='validation_error',
            details=serializer.errors,
            status_code=status.HTTP_400_BAD_REQUEST
        )


class MySocialView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        social = SimpleSocial.objects.filter(user=user).first()
        if not social:
            return api_error(
                message='No social record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND
            )
        serializer = SimpleSocialSerializer(social)
        return api_success(data=serializer.data, message='Social fetched successfully')


class UpdateSocialView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return api_error(
                message='Email parameter is required',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        social = SimpleSocial.objects.filter(user=user).first()
        if social:
            serializer = SimpleSocialSerializer(social, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return api_success(data=serializer.data, message='Social updated successfully')
            return api_error(
                message='Validation error',
                error_code='validation_error',
                details=serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )

        serializer = SimpleSocialSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return api_success(data=serializer.data, message='Social created successfully', status_code=status.HTTP_201_CREATED)
        return api_error(
            message='Validation error',
            error_code='validation_error',
            details=serializer.errors,
            status_code=status.HTTP_400_BAD_REQUEST
        )
