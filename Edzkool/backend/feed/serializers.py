from rest_framework import serializers
from django.contrib.auth.models import User
from .models import FeedCategory, Post, Comment, Like , Bookmark


class UserSerializer(serializers.ModelSerializer):
    """Basic user info for posts & comments."""
    class Meta:
        model = User
        fields = ["id", "username"]


class FeedCategorySerializer(serializers.ModelSerializer):
    """Category serializer."""
    class Meta:
        model = FeedCategory
        fields = ["id", "name"]


class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    class Meta:
        model = Comment
        fields = ['id', 'post', 'user', 'content', 'created_at']
        read_only_fields = ['id', 'created_at', 'user', 'post']



class LikeSerializer(serializers.ModelSerializer):
    """Serializer for likes."""
    user = UserSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ["id", "post", "user", "created_at"]
        read_only_fields = ["id", "created_at", "user"]


class PostSerializer(serializers.ModelSerializer):
    """Serializer for posts."""
    user = UserSerializer(read_only=True)
    category = FeedCategorySerializer(read_only=True)

    # counts
    likes_count = serializers.IntegerField(read_only=True)
    comments_count = serializers.IntegerField(read_only=True)

    # NEW FIELDS
    is_liked_by_user = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = [
            "id",
            "user",
            "category",
            "content",
            "created_at",
            "likes_count",
            "comments_count",
            "is_liked_by_user",   # 👈 added
            "comments",           # 👈 added
        ]
        read_only_fields = [
            "id",
            "created_at",
            "user",
            "likes_count",
            "comments_count"
        ]

    # 👇 Whether the authenticated user has liked this post
    def get_is_liked_by_user(self, obj):
        request = self.context.get("request")
        if request and request.user.is_authenticated:
            return obj.likes.filter(user=request.user).exists()
        return False

    # 👇 Return all comments for this post
    def get_comments(self, obj):
        from .serializers import CommentSerializer  # avoid circular import
        comments = obj.comments.all().order_by("-created_at")
        return CommentSerializer(comments, many=True).data

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username"]

class BookmarkSerializer(serializers.ModelSerializer):
    """Serializer for bookmarks."""
    user = UserSerializer(read_only=True)

    class Meta:
        model = Bookmark
        fields = ["id", "post", "user", "created_at"]
        read_only_fields = ["id", "created_at", "user"]

