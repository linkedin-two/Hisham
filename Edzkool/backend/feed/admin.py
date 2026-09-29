from django.contrib import admin
from .models import FeedCategory, Post, Comment, Like


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "category", "created_at")
    list_filter = ("category", "created_at")
    search_fields = ("content", "user__username")


@admin.register(Comment)
class CommentAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "post", "created_at")
    search_fields = ("content", "user__username")


@admin.register(Like)
class LikeAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "post", "created_at")


admin.site.register(FeedCategory)
