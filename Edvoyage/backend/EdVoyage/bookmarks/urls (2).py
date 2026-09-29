from django.urls import path
from .views import (
    FavouriteUniversityView, 
    FavouriteCourseView,
    AddFavouriteUniversity, 
    AddFavouriteCourse
)

urlpatterns = [
    # Enhanced endpoints
    path('universities/', FavouriteUniversityView.as_view(), name='favourite-universities'),
    path('courses/', FavouriteCourseView.as_view(), name='favourite-courses'),
    

]