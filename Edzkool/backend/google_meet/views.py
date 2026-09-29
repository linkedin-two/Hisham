from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView

from edvoayge.api_response import api_error, api_success
from edvoayge.auth_utils import get_user_email
from users.models import UserProfile

from .models import ClassMeetLink
from .serializers import RegisterClassSerializer


def _get_or_create_profile(user):
    profile, _ = UserProfile.objects.get_or_create(
        user=user,
        defaults={'email': user.email or ''},
    )
    if not profile.email and user.email:
        profile.email = user.email
        profile.save(update_fields=['email'])
    return profile


def _build_status_payload(profile):
    school_class = profile.school_class
    has_class = school_class is not None
    meet_url = None
    meet_configured = False

    if has_class:
        link = ClassMeetLink.objects.filter(
            class_number=school_class,
            is_active=True,
        ).first()
        if link and link.meet_url:
            meet_url = link.meet_url
            meet_configured = True

    return {
        'has_class': has_class,
        'school_class': school_class,
        'meet_url': meet_url,
        'meet_configured': meet_configured,
    }


class GoogleMeetStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        profile = _get_or_create_profile(request.user)
        return api_success(
            data=_build_status_payload(profile),
            message='Google Meet status retrieved',
        )


class RegisterClassView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = RegisterClassSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        school_class = serializer.validated_data['school_class']
        email = get_user_email(request.user)
        if not email:
            return api_error(
                message='Authenticated user has no email on file',
                error_code='missing_email',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        profile = _get_or_create_profile(request.user)

        if profile.school_class is not None:
            return api_error(
                message='Class is already set and cannot be changed',
                error_code='class_already_set',
                details={'school_class': profile.school_class},
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        profile.school_class = school_class
        profile.save(update_fields=['school_class', 'updated_at'])

        return api_success(
            data=_build_status_payload(profile),
            message='Class registered successfully',
            status_code=status.HTTP_200_OK,
        )
