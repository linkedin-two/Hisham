from django.urls import path
from .views import (
    FavouriteUniversityView, 
    FavouriteCourseView,
    AddFavouriteUniversity, 
    AddFavouriteCourse,
    CheckFavouriteUniversityView
)

urlpatterns = [
    # Enhanced endpoints
    path('universities/', FavouriteUniversityView.as_view(), name='favourite-universities'),
    path('universities/check/', CheckFavouriteUniversityView.as_view(), name='check-favourite-university'),
    path('courses/', FavouriteCourseView.as_view(), name='favourite-courses'),
    

]