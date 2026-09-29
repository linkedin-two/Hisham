from django.urls import path
from .views import CreateOTPView, HealthCheckView

urlpatterns = [
    path('health', HealthCheckView.as_view(), name='health-check-no-slash'),
    path('health/', HealthCheckView.as_view(), name='health-check-slash'),
    path('otp/create/', CreateOTPView.as_view(), name='otp-create'),
    path('send-otp/', CreateOTPView.as_view(), name='send-otp'),
]
