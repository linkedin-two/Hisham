from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from django_filters.rest_framework import DjangoFilterBackend
from edvoayge.api_response import api_success, api_error
from .models import FavouriteUniversity, FavouriteCourse
from .serializers import FavouriteUniversitySerializer, FavouriteCourseSerializer
from universities.models import University
from courses.models import Course
from users.models import User
import traceback

class FavouriteUniversityView(APIView):
    def get(self, request):
        """Get all favourite universities for the current user"""
        try:
            print("[DEBUG] DEBUG: Starting FavouriteUniversityView.get()")
            
            user_email = request.query_params.get('user_email') or request.headers.get('x-user-email')
            print(f"[DEBUG] DEBUG: Headers received: {dict(request.headers)}")
            print(f"[DEBUG] DEBUG: Getting favourites for user_email: {user_email}")
    
            print("[DEBUG] DEBUG: Attempting to filter FavouriteUniversity objects")
            try:
                if user_email:
                    favourites = FavouriteUniversity.objects.filter(email=user_email)
                else:
                    favourites = FavouriteUniversity.objects.all()
                # favourites_count = favourites.count()
                # print(f"[OK] DEBUG: Found {favourites_count} favourite universities")
                
                if favourites.exists():
                    first_fav = favourites.first()
                    print(f"[OK] DEBUG: First favourite - User: {first_fav.email}, University: {first_fav.university.name}")
                else:
                    print("ℹ️ DEBUG: No favourite universities found")
                    
            except Exception as e:
                print(f"[ERROR] DEBUG: Error filtering FavouriteUniversity: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return api_error(
                    message=f'Database error: {str(e)}',
                    error_code='database_error',
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            print("[DEBUG] DEBUG: Attempting to serialize data")
            try:
                serializer = FavouriteUniversitySerializer(favourites, many=True)
                print(f"[OK] DEBUG: Serialization successful, data count: {len(serializer.data)}")
            except Exception as e:
                print(f"[ERROR] DEBUG: Error serializing data: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return api_error(
                    message=f'Serialization error: {str(e)}',
                    error_code='serialization_error',
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            print("[OK] DEBUG: Returning successful response")
            return api_success(
                data={
                    'data': serializer.data,
                    'count': len(serializer.data)
                },
                message='Favourite universities retrieved successfully'
            )
            
        except Exception as e:
            print(f"[ERROR] DEBUG: Unexpected error in FavouriteUniversityView.get(): {str(e)}")
            print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
            return api_error(
                message=f'Unexpected error: {str(e)}',
                error_code='unexpected_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request):
        """Add a university to favourites"""
        try:
            print("[DEBUG] DEBUG: Starting FavouriteUniversityView.post()")
            
            university_id = request.data.get('university_id')
            print(f"[DEBUG] DEBUG: Received university_id: {university_id}")
            
            if not university_id:
                print("[ERROR] DEBUG: No university_id provided")
                return api_error(
                    message='university_id is required',
                    error_code='missing_university_id',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            print("[DEBUG] DEBUG: Attempting to get university")
            try:
                university = University.objects.get(id=university_id)
                print(f"[OK] DEBUG: Found university: {university.name} (ID: {university.id})")
            except University.DoesNotExist:
                print(f"[ERROR] DEBUG: University with ID={university_id} not found")
                return api_error(
                    message='University not found',
                    error_code='university_not_found',
                    status_code=status.HTTP_404_NOT_FOUND
                )
            except Exception as e:
                print(f"[ERROR] DEBUG: Error getting university: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error getting university: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            # For testing purposes, use user ID = 1
            print("[DEBUG] DEBUG: Attempting to get test user")
            try:
                test_user = User.objects.get(id=1)
                print(f"[OK] DEBUG: Found test user: {test_user.username} (ID: {test_user.id})")
            except User.DoesNotExist:
                print("[ERROR] DEBUG: User with ID=1 does not exist")
                return Response({
                    'status': 'error',
                    'message': 'Test user not found. Please create a user with ID=1'
                }, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error getting user: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error getting user: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            # Check if already favourited
            print("[DEBUG] DEBUG: Checking if already favourited")
            user_email = request.data.get('user_email') or request.headers.get('X-User-Email')
            if not user_email:
                print("[ERROR] DEBUG: No user_email provided in body or X-User-Email header")
                return api_error(
                    message='user_email is required',
                    error_code='missing_user_email',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            try:
                if FavouriteUniversity.objects.filter(email=user_email, university=university).exists():
                    # delete it
                    FavouriteUniversity.objects.filter(email=user_email, university=university).delete()
                    print("[OK] DEBUG: University already in favourites, removing it")
                    return Response({
                        'status': 'success',
                        'message': 'University removed from favourites'
                    }, status=status.HTTP_200_OK)
                print("[OK] DEBUG: University not in favourites, proceeding to add")
            except Exception as e:
                print(f"[ERROR] DEBUG: Error checking existing favourite: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error checking existing favourite: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            print("[DEBUG] DEBUG: Creating new favourite")
            try:
                favourite = FavouriteUniversity.objects.create(email=user_email, university=university)
                print(f"[OK] DEBUG: Created favourite - User: {favourite.email}, University: {favourite.university.name}")
            except Exception as e:
                print(f"[ERROR] DEBUG: Error creating favourite: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error creating favourite: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            print("[DEBUG] DEBUG: Serializing response")
            try:
                serializer = FavouriteUniversitySerializer(favourite)
                print("[OK] DEBUG: Serialization successful")
            except Exception as e:
                print(f"[ERROR] DEBUG: Error serializing response: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error serializing response: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            print("[OK] DEBUG: Returning successful response")
            return Response({
                'status': 'success',
                'message': 'University added to favourites',
                'data': serializer.data
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            print(f"[ERROR] DEBUG: Unexpected error in FavouriteUniversityView.post(): {str(e)}")
            print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
            return Response({
                'status': 'error',
                'message': f'Unexpected error: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    def delete(self, request):
        """Remove a university from favourites"""
        try:
            print("[DEBUG] DEBUG: Starting FavouriteUniversityView.delete()")
            
            university_id = request.data.get('university_id')
            print(f"[DEBUG] DEBUG: Received university_id: {university_id}")
            
            if not university_id:
                print("[ERROR] DEBUG: No university_id provided")
                return api_error(
                    message='university_id is required',
                    error_code='missing_university_id',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # For testing purposes, use user ID = 1
            print("[DEBUG] DEBUG: Attempting to get test user")
            try:
                test_user = User.objects.get(id=1)
                print(f"[OK] DEBUG: Found test user: {test_user.username} (ID: {test_user.id})")
            except User.DoesNotExist:
                print("[ERROR] DEBUG: User with ID=1 does not exist")
                return Response({
                    'status': 'error',
                    'message': 'Test user not found. Please create a user with ID=1'
                }, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error getting user: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error getting user: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            print("[DEBUG] DEBUG: Attempting to delete favourite")
            user_email = request.data.get('user_email') or request.headers.get('X-User-Email')
            if not user_email:
                print("[ERROR] DEBUG: No user_email provided in body or X-User-Email header")
                return api_error(
                    message='user_email is required',
                    error_code='missing_user_email',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            try:
                favourite = FavouriteUniversity.objects.get(email=user_email, university_id=university_id)
                print(f"[OK] DEBUG: Found favourite to delete - User: {favourite.email}, University: {favourite.university.name}")
                favourite.delete()
                print("[OK] DEBUG: Favourite deleted successfully")
            except FavouriteUniversity.DoesNotExist:
                print(f"[ERROR] DEBUG: Favourite not found for user ID=1 and university ID={university_id}")
                return Response({
                    'status': 'error',
                    'message': 'University not in favourites'
                }, status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error deleting favourite: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error deleting favourite: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
            
            print("[OK] DEBUG: Returning successful response")
            return Response({
                'status': 'success',
                'message': 'University removed from favourites'
            })
            
        except Exception as e:
            print(f"[ERROR] DEBUG: Unexpected error in FavouriteUniversityView.delete(): {str(e)}")
            print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
            return Response({
                'status': 'error',
                'message': f'Unexpected error: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class FavouriteCourseView(APIView):
    def get(self, request):
        """Get all favourite courses for the current user"""
        user_email = request.query_params.get('user_email') or request.headers.get('x-user-email')
        print(f"[DEBUG] DEBUG: Getting favourites for user_email: {user_email}")
        print(f"[DEBUG] DEBUG: All headers received: {dict(request.headers)}")
        print(f"[DEBUG] DEBUG: Query params: {request.query_params}")
        
        if user_email:
            favourites = FavouriteCourse.objects.filter(email=user_email)
        else:
            favourites = FavouriteCourse.objects.all()
            
        print("[DEBUG] DEBUG: Favourites found:", favourites)
        serializer = FavouriteCourseSerializer(favourites, many=True)
        print("[DEBUG] DEBUG: Serialized data:", serializer.data)
        return api_success(
            data={
                'data': serializer.data,
                'count': len(serializer.data)
            },
            message='Favourite courses retrieved successfully'
        )
    
    def post(self, request):
        print("*******",request.data)
        """Add a course to favourites"""
        course_id = request.data.get('course_id')
        user_email = request.data.get('user_email')
        if not course_id:
            return Response({
                'status': 'error',
                'message': 'course_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            course = Course.objects.get(id=course_id)
        except Course.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Course not found'
            }, status=status.HTTP_404_NOT_FOUND)


        
        # Check if already favourited
        if FavouriteCourse.objects.filter(email=user_email, course=course).exists():
            obj=FavouriteCourse.objects.get(email=user_email, course=course)
            print("The to dlete the obj is",obj.email,obj.course)
            obj.delete()
            print("[DEBUG] DEBUG: Course already in favourites, removing it")
            return api_success(
                data={'action': 'removed'},
                message='Course removed from favourites'
            )
        else:
            FavouriteCourse.objects.create(email=user_email, course=course)
            print("[DEBUG] DEBUG: Course not in favourites, adding it")
            return api_success(
                data={'action': 'added'},
                message='Course added to favourites',
                status_code=status.HTTP_201_CREATED
            )

        
        favourite = FavouriteCourse.objects.create(email=user_email, course=course)
        serializer = FavouriteCourseSerializer(favourite)
        print("The data for the favourite serializers are", serializer.data)
        return Response({
            'status': 'success',
            'message': 'Course added to favourites',
            'data': serializer.data
        }, status=status.HTTP_201_CREATED)
    
    def delete(self, request):
        """Remove a course from favourites"""
        course_id = request.data.get('course_id')
        if not course_id:
            return Response({
                'status': 'error',
                'message': 'course_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # For testing purposes, use user ID = 1
        user_email = request.data.get('user_email')
        
        try:
            favourite = FavouriteCourse.objects.get(email=user_email, course_id=course_id)
            favourite.delete()
            return Response({
                'status': 'success',
                'message': 'Course removed from favourites'
            })
        except FavouriteCourse.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Course not in favourites'
            }, status=status.HTTP_404_NOT_FOUND)

# Legacy views for backward compatibility
class AddFavouriteUniversity(APIView):
    def post(self, request):
        
        print("[DEBUG] DEBUG: Starting AddFavouriteUniversity.post()")
        print(f"[DEBUG] DEBUG: Request data: {request.data}")
        print(f"[DEBUG] DEBUG: Request method: {request.method}")
        print(f"[DEBUG] DEBUG: Content type: {request.content_type}")    
        
        # Check for both field names for compatibility
        university_id = request.data.get('university_id') or request.data.get('university')
        user_email = request.data.get('user_email')
        print(f"[DEBUG] DEBUG: Extracted university_id: {university_id}, user_email: {user_email}")
        
        if not university_id:
            print("[ERROR] DEBUG: No university_id/university provided in request data")
            print(f"[ERROR] DEBUG: Available keys in request.data: {list(request.data.keys())}")
            return Response({
                'status': 'error',
                'message': 'university_id or university is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        if not user_email:
            print("[ERROR] DEBUG: No user_email provided in request data")
            return Response({
                'status': 'error',
                'message': 'user_email is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        print(f"[DEBUG] DEBUG: Attempting to get university with ID: {university_id}")
        try:
            university = University.objects.get(id=university_id)
            print(f"[OK] DEBUG: Found university: {university.name} (ID: {university.id})")
        except University.DoesNotExist:
            print(f"[ERROR] DEBUG: University with ID={university_id} not found")
            return Response({
                'status': 'error',
                'message': 'University not found'
            }, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            print(f"[ERROR] DEBUG: Error getting university: {str(e)}")
            print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
            return Response({
                'status': 'error',
                'message': f'Error getting university: {str(e)}'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        print("[DEBUG] DEBUG: Checking if university is already in favourites")
        existing_favourite = FavouriteUniversity.objects.filter(email=user_email, university=university).first()
        
        if existing_favourite:
            # University already exists in favourites, so delete it (toggle off)
            print(f"[DEBUG] DEBUG: University {university.name} is already in favourites for user {user_email}, removing it...")
            try:
                existing_favourite.delete()
                print(f"[OK] DEBUG: Successfully removed favourite: User={user_email}, University={university.name}")
                return Response({
                    'status': 'success',
                    'message': 'University removed from favourites',
                    'action': 'removed'
                }, status=status.HTTP_200_OK)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error removing favourite: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error removing favourite: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        else:
            # University doesn't exist in favourites, so create it (toggle on)
            print("[DEBUG] DEBUG: Creating new favourite university entry")
            try:
                favourite = FavouriteUniversity.objects.create(email=user_email, university=university)
                print(f"[OK] DEBUG: Successfully created favourite: User={user_email}, University={university.name}")
                return Response({
                    'status': 'success',
                    'message': 'University added to favourites',
                    'action': 'added'
                }, status=status.HTTP_201_CREATED)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error creating favourite: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error creating favourite: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class AddFavouriteCourse(APIView):
    def post(self, request):
        print("[DEBUG] DEBUG: Starting AddFavouriteCourse.post()")
        print(f"[DEBUG] DEBUG: Request data: {request.data}")
        print(f"[DEBUG] DEBUG: Request method: {request.method}")
        print(f"[DEBUG] DEBUG: Content type: {request.content_type}")
        
        course_id = request.data.get('course_id')
        user_email = request.data.get('user_email')
        
        print(f"[DEBUG] DEBUG: Extracted course_id: {course_id}")
        
        if not course_id:
            print("[ERROR] DEBUG: No course_id provided in request data")
            print(f"[ERROR] DEBUG: Available keys in request.data: {list(request.data.keys())}")
            return Response({
                'status': 'error',
                'message': 'course_id is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            course = Course.objects.get(id=course_id)
        except Course.DoesNotExist:
            return Response({
                'status': 'error',
                'message': 'Course not found'
            }, status=status.HTTP_404_NOT_FOUND)
        
        
        
        existing_favourite = FavouriteCourse.objects.filter(email=user_email, course=course).first()
        
        if existing_favourite:
            print(f"[DEBUG] DEBUG: Course {course.name} is already in favourites for user {user_email}, removing it...")
            try:
                existing_favourite.delete()
                print(f"[OK] DEBUG: Successfully removed favourite course: User={user_email}, Course={course.name}")
                return Response({
                    'status': 'success',
                    'message': 'Course removed from favourites',
                    'action': 'removed'
                }, status=status.HTTP_200_OK)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error removing favourite course: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error removing favourite course: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        else:
            # Course doesn't exist in favourites, so create it (toggle on)
            print("[DEBUG] DEBUG: Creating new favourite course entry")
            try:
                favourite = FavouriteCourse.objects.create(email=user_email, course=course)
                print(f"[OK] DEBUG: Successfully created favourite course: User={user_email}, Course={course.name}")
                return Response({
                    'status': 'success',
                    'message': 'Course added to favourites',
                    'action': 'added'
                }, status=status.HTTP_201_CREATED)
            except Exception as e:
                print(f"[ERROR] DEBUG: Error creating favourite course: {str(e)}")
                print(f"[ERROR] DEBUG: Traceback: {traceback.format_exc()}")
                return Response({
                    'status': 'error',
                    'message': f'Error creating favourite course: {str(e)}'
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class CheckFavouriteUniversityView(APIView):
    """Check if a specific user follows a specific university."""
    
    def get(self, request):
        """Check if user follows a specific university."""
        try:
            user_email = request.headers.get('x-user-email') or request.query_params.get('user_email')
            university_id = request.query_params.get('university_id')
            
            if not user_email:
                return api_error(
                    message='user_email is required',
                    error_code='missing_user_email',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            if not university_id:
                return api_error(
                    message='university_id is required',
                    error_code='missing_university_id',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Check if university exists
            try:
                university = University.objects.get(id=university_id)
            except University.DoesNotExist:
                return api_error(
                    message='University not found',
                    error_code='university_not_found',
                    status_code=status.HTTP_404_NOT_FOUND
                )
            
            # Check if favourite exists
            is_following = FavouriteUniversity.objects.filter(
                email=user_email, 
                university=university
            ).exists()
            
            return api_success(
                data={
                    'is_following': is_following,
                    'university_id': university_id,
                    'user_email': user_email
                },
                message='Follow status retrieved successfully'
            )
            
        except Exception as e:
            return api_error(
                message=f'Error checking follow status: {str(e)}',
                error_code='check_error',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
