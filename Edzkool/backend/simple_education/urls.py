from django.urls import path

from .views import (
    MyEducationView,
    UpdateEducationView,
    MyWorkView,
    UpdateWorkView,
    MySocialView,
    UpdateSocialView,
)

app_name = 'simple_education'

urlpatterns = [
    path('education/my_education/', MyEducationView.as_view()),
    path('education/update_education/', UpdateEducationView.as_view()),
    path('work/my_work/', MyWorkView.as_view()),
    path('work/update_work/', UpdateWorkView.as_view()),
    path('social/my_social/', MySocialView.as_view()),
    path('social/update_social/', UpdateSocialView.as_view()),
]