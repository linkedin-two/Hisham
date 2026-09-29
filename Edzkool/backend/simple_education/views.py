from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.contrib.auth import get_user_model
from django.db.models import Q
from edvoayge.api_response import api_success, api_error
from edvoayge.auth_utils import get_user_email

from .models import SimpleEducation, SimpleWork, SimpleSocial
from .serializers import SimpleEducationSerializer, SimpleWorkSerializer, SimpleSocialSerializer


def _require_user(request):
    user = request.user
    if not user or not user.is_authenticated:
        return None
    return user


class MyEducationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = _require_user(request)
        education = SimpleEducation.objects.filter(user=user).first()
        if not education:
            return api_error(
                message='No education record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )
        return api_success(data=SimpleEducationSerializer(education).data, message='Education retrieved')

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleEducationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        education, _ = SimpleEducation.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleEducationSerializer(education).data,
            message='Education updated',
            status_code=status.HTTP_200_OK,
        )


class UpdateEducationView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleEducationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        education, _ = SimpleEducation.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleEducationSerializer(education).data,
            message='Education updated',
            status_code=status.HTTP_200_OK,
        )


class MyWorkView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = _require_user(request)
        work = SimpleWork.objects.filter(user=user).first()
        if not work:
            return api_error(
                message='No work record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )
        return api_success(data=SimpleWorkSerializer(work).data, message='Work retrieved')

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleWorkSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        work, _ = SimpleWork.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleWorkSerializer(work).data,
            message='Work updated',
            status_code=status.HTTP_200_OK,
        )


class UpdateWorkView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleWorkSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        work, _ = SimpleWork.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleWorkSerializer(work).data,
            message='Work updated',
            status_code=status.HTTP_200_OK,
        )


class MySocialView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = _require_user(request)
        social = SimpleSocial.objects.filter(user=user).first()
        if not social:
            return api_error(
                message='No social record found',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )
        return api_success(data=SimpleSocialSerializer(social).data, message='Social links retrieved')

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleSocialSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        social, _ = SimpleSocial.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleSocialSerializer(social).data,
            message='Social links updated',
            status_code=status.HTTP_200_OK,
        )


class UpdateSocialView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = _require_user(request)
        serializer = SimpleSocialSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        social, _ = SimpleSocial.objects.update_or_create(
            user=user,
            defaults=serializer.validated_data,
        )
        return api_success(
            data=SimpleSocialSerializer(social).data,
            message='Social links updated',
            status_code=status.HTTP_200_OK,
        )
