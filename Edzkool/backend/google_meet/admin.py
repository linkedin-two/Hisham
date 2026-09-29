from django.contrib import admin

from .forms import ClassMeetLinkForm
from .models import ClassMeetLink


@admin.register(ClassMeetLink)
class ClassMeetLinkAdmin(admin.ModelAdmin):
    form = ClassMeetLinkForm
    list_display = ('class_number', 'meet_url', 'is_active', 'updated_at')
    list_editable = ('meet_url', 'is_active')
    ordering = ('class_number',)
    search_fields = ('meet_url',)
