from django.contrib import admin
from .models import UserSimple, Conversation, Message


@admin.register(UserSimple)
class UserSimpleAdmin(admin.ModelAdmin):
    list_display = ['email', 'name', 'role', 'is_active', 'created_at']
    list_filter = ['is_active', 'role', 'created_at']
    search_fields = ['email', 'name']
    readonly_fields = ['created_at']


@admin.register(Conversation)
class ConversationAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_a', 'user_b', 'created_at']
    list_filter = ['created_at']
    search_fields = ['user_a__email', 'user_b__email']
    readonly_fields = ['created_at']


@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['id', 'sender', 'conversation', 'text_preview', 'timestamp', 'delivered', 'seen', 'is_deleted']
    list_filter = ['timestamp', 'delivered', 'seen', 'is_edited', 'is_deleted']
    search_fields = ['text', 'sender__email']
    readonly_fields = ['timestamp', 'edited_at']
    
    def text_preview(self, obj):
        return obj.text[:50] + '...' if len(obj.text) > 50 else obj.text
    text_preview.short_description = 'Text Preview'
