from rest_framework import serializers
from .models import Notification


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['title', 'subtitle', 'description', 'is_offer', 'created_at']
        read_only_fields = ['title', 'subtitle', 'description', 'is_offer', 'created_at']