from rest_framework.generics import ListCreateAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from django.db.models import Q


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
        return Response(serializer.data)

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

    def create(self, request, *args, **kwargs):
        email = request.data.get('email') or request.query_params.get('email')
        user = None
        if email:
            user = self._get_or_create_user_from_email(email)

        user_id = self.kwargs.get("user_id")
        if user_id is None:
            user_id = 1
        category_id = self.kwargs.get("category_id")

        if not user:
            user = get_object_or_404(User, id=user_id)
        category = None
        if category_id and category_id != "all":
            category = get_object_or_404(FeedCategory, id=category_id)

        content = request.data.get("content")
        if not content:
            return Response(
                {"success": False, "message": "content is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        post = Post.objects.create(user=user, category=category, content=content)
        serializer = PostSerializer(post, context={"request": request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)



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

        return Response(serializer.data, status=status.HTTP_201_CREATED)



class ToggleLikeAPIView(APIView):
    """
    Toggle like for a post:
    - If user already liked => remove like
    - If user has not liked => create like
    """
    def post(self, request, post_id,user_id):
        if user_id is None:
            user_id = 1  # Default to user with ID 1 for testing purposes
        user = get_object_or_404(User, id=user_id)
        post = get_object_or_404(Post, id=post_id)

        # Check if like already exists
        existing_like = Like.objects.filter(post=post, user=user).first()

        if existing_like:
            # Unlike
            existing_like.delete()
            return Response(
                {"status": "unliked"},
                status=status.HTTP_200_OK
            )

        # Like
        new_like = Like.objects.create(post=post, user=user)
        serializer = LikeSerializer(new_like)

        return Response(
            {"status": "liked", "like": serializer.data},
            status=status.HTTP_201_CREATED
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
    def post(self, request, post_id,user_id):
        user = get_object_or_404(User, id=1)
        post = get_object_or_404(Post, id=2)

        # Check if bookmark already exists
        existing_bookmark = Bookmark.objects.filter(post=post, user=user).first()

        if existing_bookmark:
            # Remove bookmark
            existing_bookmark.delete()
            return Response(
                {"status": "bookmark removed"},
                status=status.HTTP_200_OK
            )

        # Add bookmark
        new_bookmark = Bookmark.objects.create(post=post, user=user)
        serializer = BookmarkSerializer(new_bookmark)

        return Response(
            {"status": "bookmarked", "bookmark": serializer.data},
            status=status.HTTP_201_CREATED
        )
    


