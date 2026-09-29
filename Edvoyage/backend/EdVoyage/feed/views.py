from rest_framework.generics import ListCreateAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.db.models import Q
from edvoayge.api_response import api_success, api_error


from .models import Post, Comment, Like , User , Bookmark , FeedCategory
from .serializers import (
    PostSerializer,
    CommentSerializer,
    LikeSerializer,
    UserSerializer,
    BookmarkSerializer,
    FeedCategorySerializer,
)


# -------------------------
# POSTS (Create + List)
# -------------------------

class FeedCategoryView(APIView):
    permission_classes = []
    
    def get(self, request):
        categories = FeedCategory.objects.all()
        serializer = FeedCategorySerializer(categories, many=True)
        return api_success(data=serializer.data, message="Categories retrieved successfully")

class PostListCreateAPIView(ListCreateAPIView):
    permission_classes = []
    serializer_class = PostSerializer

    def _get_or_create_user_from_email(self, email: str):
        email = (email or '').strip()
        if not email:
            return None

        user = User.objects.filter(Q(email__iexact=email)).first()
        if user:
            return user

        base_username = email
        username = base_username
        suffix = 1
        while User.objects.filter(username__iexact=username).exists():
            suffix += 1
            username = f"{base_username}{suffix}"

        user = User.objects.create(username=username, email=email)
        return user

    def get_queryset(self):
        category_id = self.kwargs.get("category_id")

        if category_id == "all":
            return Post.objects.all().order_by("-created_at")
        return Post.objects.filter(category_id=category_id).order_by("-created_at")

    def get_serializer_context(self):
        return {"request": self.request}

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return api_success(data=serializer.data, message="Posts retrieved successfully")

    def create(self, request, *args, **kwargs):
        email = request.data.get('email') or request.query_params.get('email')
        
        if not email:
            return api_error(
                message="email is required",
                error_code="missing_email",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        user = self._get_or_create_user_from_email(email)
        if not user:
            return api_error(
                message="Could not create or find user with provided email",
                error_code="user_creation_failed",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        category_id = self.kwargs.get("category_id")
        category = None
        if category_id and category_id != "all":
            category = get_object_or_404(FeedCategory, id=category_id)

        content = request.data.get("content")
        if not content:
            return api_error(
                message="content is required",
                error_code="missing_content",
                status_code=status.HTTP_400_BAD_REQUEST
            )

        post = Post.objects.create(user=user, category=category, content=content)
        serializer = PostSerializer(post, context={"request": request})
        return api_success(data=serializer.data, message="Post created successfully", status_code=status.HTTP_201_CREATED)



# -------------------------
# COMMENTS (Create + List)
# -------------------------


from rest_framework.generics import ListCreateAPIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Comment, Post, User
from .serializers import CommentSerializer


class CommentListCreateAPIView(ListCreateAPIView):
    serializer_class = CommentSerializer

    def get_queryset(self):
        post_id = self.kwargs["post_id"]
        return Comment.objects.filter(post_id=post_id).order_by("-created_at")

    def create(self, request, *args, **kwargs):
        post_id = self.kwargs["post_id"]
        post = get_object_or_404(Post, id=post_id) 
        email = request.data.get('email') or request.query_params.get('email')
        user = None
        if email:
            user = User.objects.filter(Q(email__iexact=email)).first()
            if not user:
                base_username = (email or '').strip()
                username = base_username
                suffix = 1
                while User.objects.filter(username__iexact=username).exists():
                    suffix += 1
                    username = f"{base_username}{suffix}"
                user = User.objects.create(username=username, email=email)

        if not user:
            user = get_object_or_404(User, id=1)

        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        # Pass actual Post instance and User instance
        serializer.save(user=user, post=post)

        return api_success(data=serializer.data, message="Comment created successfully", status_code=status.HTTP_201_CREATED)



class ToggleLikeAPIView(APIView):
    """
    Toggle like for a post:
    - If user already liked => remove like
    - If user has not liked => create like
    """
    def _get_or_create_user_from_email(self, email: str):
        email = (email or '').strip()
        if not email:
            return None

        user = User.objects.filter(Q(email__iexact=email)).first()
        if user:
            return user

        base_username = email
        username = base_username
        suffix = 1
        while User.objects.filter(username__iexact=username).exists():
            suffix += 1
            username = f"{base_username}{suffix}"

        user = User.objects.create(username=username, email=email)
        return user

    def post(self, request, post_id):
        email = request.data.get('email') or request.query_params.get('email')
        
        if not email:
            return api_error(
                message="email is required",
                error_code="missing_email",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        user = self._get_or_create_user_from_email(email)
        if not user:
            return api_error(
                message="Could not create or find user with provided email",
                error_code="user_creation_failed",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        post = get_object_or_404(Post, id=post_id)

        # Check if like already exists
        existing_like = Like.objects.filter(post=post, user=user).first()

        if existing_like:
            # Unlike
            existing_like.delete()
            return api_success(
                data={"status": "unliked"},
                message="Post unliked successfully"
            )

        # Like
        new_like = Like.objects.create(post=post, user=user)
        serializer = LikeSerializer(new_like)

        return api_success(
            data={"status": "liked", "like": serializer.data},
            message="Post liked successfully",
            status_code=status.HTTP_201_CREATED
        )

#  a view to get the full users only
class UserListAPIView(ListCreateAPIView):
    permission_classes = []
    serializer_class = UserSerializer

    def get_queryset(self):
        return User.objects.all()

# a view for bookmarking posts (toggle )

class ToggleBookmarkAPIView(APIView):
    """
    Toggle bookmark for a post:
    - If user already bookmarked => remove bookmark
    - If user has not bookmarked => create bookmark
    """
    def post(self, request, post_id):
        email = request.data.get('email') or request.query_params.get('email')
        
        if not email:
            return api_error(
                message="email is required",
                error_code="missing_email",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        user = User.objects.filter(Q(email__iexact=email)).first()
        if not user:
            return api_error(
                message="User not found with provided email",
                error_code="user_not_found",
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        post = get_object_or_404(Post, id=post_id)

        # Check if bookmark already exists
        existing_bookmark = Bookmark.objects.filter(post=post, user=user).first()

        if existing_bookmark:
            # Remove bookmark
            existing_bookmark.delete()
            return api_success(
                data={"status": "bookmark removed"},
                message="Bookmark removed successfully"
            )

        # Add bookmark
        new_bookmark = Bookmark.objects.create(post=post, user=user)
        serializer = BookmarkSerializer(new_bookmark)

        return api_success(
            data={"status": "bookmarked", "bookmark": serializer.data},
            message="Post bookmarked successfully",
            status_code=status.HTTP_201_CREATED
        )
    


