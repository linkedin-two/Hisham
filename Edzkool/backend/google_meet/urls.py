from django.urls import path

from .views import GoogleMeetStatusView, RegisterClassView

urlpatterns = [
    path('status/', GoogleMeetStatusView.as_view(), name='google-meet-status'),
    path('register-class/', RegisterClassView.as_view(), name='google-meet-register-class'),
]
