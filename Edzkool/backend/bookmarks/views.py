from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from edvoayge.api_response import api_success, api_error
from edvoayge.auth_utils import get_user_email
from .models import FavouriteUniversity, FavouriteCourse
from .serializers import FavouriteUniversitySerializer, FavouriteCourseSerializer
from universities.models import University
from courses.models import Course


def _user_email(request):
    return get_user_email(request.user)


class FavouriteUniversityView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_email = _user_email(request)
        favourites = FavouriteUniversity.objects.filter(email=user_email)
        serializer = FavouriteUniversitySerializer(favourites, many=True)
        return api_success(
            data={'data': serializer.data, 'count': len(serializer.data)},
            message='Favourite universities retrieved successfully',
        )

    def post(self, request):
        university_id = request.data.get('university_id')
        if not university_id:
            return api_error(
                message='university_id is required',
                error_code='missing_university_id',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        university = University.objects.filter(id=university_id).first()
        if not university:
            return api_error(
                message='University not found',
                error_code='university_not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        user_email = _user_email(request)
        existing = FavouriteUniversity.objects.filter(email=user_email, university=university).first()
        if existing:
            existing.delete()
            return api_success(data={'action': 'removed'}, message='University removed from favourites')

        favourite = FavouriteUniversity.objects.create(email=user_email, university=university)
        serializer = FavouriteUniversitySerializer(favourite)
        return api_success(
            data={'action': 'added', 'data': serializer.data},
            message='University added to favourites',
            status_code=status.HTTP_201_CREATED,
        )

    def delete(self, request):
        university_id = request.data.get('university_id')
        if not university_id:
            return api_error(
                message='university_id is required',
                error_code='missing_university_id',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user_email = _user_email(request)
        favourite = FavouriteUniversity.objects.filter(email=user_email, university_id=university_id).first()
        if not favourite:
            return api_error(
                message='University not in favourites',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )
        favourite.delete()
        return api_success(data=None, message='University removed from favourites')


class FavouriteCourseView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_email = _user_email(request)
        favourites = FavouriteCourse.objects.filter(email=user_email)
        serializer = FavouriteCourseSerializer(favourites, many=True)
        return api_success(
            data={'data': serializer.data, 'count': len(serializer.data)},
            message='Favourite courses retrieved successfully',
        )

    def post(self, request):
        course_id = request.data.get('course_id')
        if not course_id:
            return api_error(
                message='course_id is required',
                error_code='missing_course_id',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        course = Course.objects.filter(id=course_id).first()
        if not course:
            return api_error(
                message='Course not found',
                error_code='course_not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        user_email = _user_email(request)
        existing = FavouriteCourse.objects.filter(email=user_email, course=course).first()
        if existing:
            existing.delete()
            return api_success(data={'action': 'removed'}, message='Course removed from favourites')

        FavouriteCourse.objects.create(email=user_email, course=course)
        return api_success(
            data={'action': 'added'},
            message='Course added to favourites',
            status_code=status.HTTP_201_CREATED,
        )

    def delete(self, request):
        course_id = request.data.get('course_id')
        if not course_id:
            return api_error(
                message='course_id is required',
                error_code='missing_course_id',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        user_email = _user_email(request)
        favourite = FavouriteCourse.objects.filter(email=user_email, course_id=course_id).first()
        if not favourite:
            return api_error(
                message='Course not in favourites',
                error_code='not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )
        favourite.delete()
        return api_success(data=None, message='Course removed from favourites')


class AddFavouriteUniversity(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return FavouriteUniversityView().post(request)


class AddFavouriteCourse(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        return FavouriteCourseView().post(request)


class CheckFavouriteUniversityView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_email = _user_email(request)
        university_id = request.query_params.get('university_id')
        if not university_id:
            return api_error(
                message='university_id is required',
                error_code='missing_university_id',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        university = University.objects.filter(id=university_id).first()
        if not university:
            return api_error(
                message='University not found',
                error_code='university_not_found',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        is_following = FavouriteUniversity.objects.filter(email=user_email, university=university).exists()
        return api_success(
            data={'is_following': is_following, 'university_id': university_id, 'user_email': user_email},
            message='Follow status retrieved successfully',
        )
