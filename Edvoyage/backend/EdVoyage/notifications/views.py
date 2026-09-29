from rest_framework.generics import ListAPIView
from django_filters.rest_framework import DjangoFilterBackend
from edvoayge.api_response import api_success, api_error
from rest_framework.permissions import AllowAny

from .models import Notification
from .serializers import NotificationSerializer


class NotificationListView(ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return Notification.objects.all().order_by('-created_at')


class OfferNotificationListView(ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return Notification.objects.filter(is_offer=True).order_by('-created_at')


class NonOfferNotificationListView(ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        return Notification.objects.filter(is_offer=False).order_by('-created_at')
