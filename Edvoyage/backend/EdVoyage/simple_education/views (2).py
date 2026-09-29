from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from django.contrib.auth import get_user_model
from django.db.models import Q

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
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        education = SimpleEducation.objects.filter(user=user).first()
        if not education:
            return Response(
                {'success': False, 'message': 'No education record found'},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = SimpleEducationSerializer(education)
        return Response(
            {'success': True, 'message': 'Education fetched successfully', 'data': serializer.data},
            status=status.HTTP_200_OK,
        )


class UpdateEducationView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        education = SimpleEducation.objects.filter(user=user).first()
        if education:
            serializer = SimpleEducationSerializer(education, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return Response(
                    {'success': True, 'message': 'Education updated successfully', 'data': serializer.data},
                    status=status.HTTP_200_OK,
                )
            return Response(
                {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = SimpleEducationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response(
                {'success': True, 'message': 'Education created successfully', 'data': serializer.data},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class MyWorkView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        work = SimpleWork.objects.filter(user=user).first()
        if not work:
            return Response(
                {'success': False, 'message': 'No work record found'},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = SimpleWorkSerializer(work)
        return Response(
            {'success': True, 'message': 'Work fetched successfully', 'data': serializer.data},
            status=status.HTTP_200_OK,
        )


class UpdateWorkView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        work = SimpleWork.objects.filter(user=user).first()
        if work:
            serializer = SimpleWorkSerializer(work, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return Response(
                    {'success': True, 'message': 'Work updated successfully', 'data': serializer.data},
                    status=status.HTTP_200_OK,
                )
            return Response(
                {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = SimpleWorkSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response(
                {'success': True, 'message': 'Work created successfully', 'data': serializer.data},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )


class MySocialView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        social = SimpleSocial.objects.filter(user=user).first()
        if not social:
            return Response(
                {'success': False, 'message': 'No social record found'},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = SimpleSocialSerializer(social)
        return Response(
            {'success': True, 'message': 'Social fetched successfully', 'data': serializer.data},
            status=status.HTTP_200_OK,
        )


class UpdateSocialView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        user = _resolve_user_from_request(request)
        if not user:
            return Response(
                {'success': False, 'message': 'Email parameter is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        social = SimpleSocial.objects.filter(user=user).first()
        if social:
            serializer = SimpleSocialSerializer(social, data=request.data, partial=True)
            if serializer.is_valid():
                serializer.save(user=user)
                return Response(
                    {'success': True, 'message': 'Social updated successfully', 'data': serializer.data},
                    status=status.HTTP_200_OK,
                )
            return Response(
                {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )

        serializer = SimpleSocialSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=user)
            return Response(
                {'success': True, 'message': 'Social created successfully', 'data': serializer.data},
                status=status.HTTP_201_CREATED,
            )
        return Response(
            {'success': False, 'message': 'Validation error', 'errors': serializer.errors},
            status=status.HTTP_400_BAD_REQUEST,
        )
