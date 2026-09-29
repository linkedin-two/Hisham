from django.contrib import admin

from .models import Notification


@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ['title', 'subtitle', 'is_offer', 'created_at']
    list_filter = ['is_offer', 'created_at']
    search_fields = ['title', 'subtitle', 'description']
    readonly_fields = ['id', 'created_at']
    date_hierarchy = 'created_at'
