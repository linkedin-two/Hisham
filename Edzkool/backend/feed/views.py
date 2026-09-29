from rest_framework.generics import ListCreateAPIView
from rest_framework.permissions import IsAuthenticated, IsAuthenticatedOrReadOnly
from rest_framework import status
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from edvoayge.api_response import api_success, api_error
from edvoayge.auth_utils import get_or_create_django_user, get_user_email

from .models import Post, Comment, Like, User, Bookmark, FeedCategory
from .serializers import (
    PostSerializer,
    CommentSerializer,
    LikeSerializer,
    UserSerializer,
    BookmarkSerializer,
    FeedCategorySerializer,
)


class FeedCategoryView(APIView):
    permission_classes = [IsAuthenticatedOrReadOnly]

    def get(self, request):
        categories = FeedCategory.objects.all()
        serializer = FeedCategorySerializer(categories, many=True)
        return api_success(data=serializer.data, message='Categories retrieved successfully')


class PostListCreateAPIView(ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    serializer_class = PostSerializer

    def get_queryset(self):
        category_id = self.kwargs.get('category_id')
        if category_id == 'all':
            return Post.objects.all().order_by('-created_at')
        return Post.objects.filter(category_id=category_id).order_by('-created_at')

    def get_serializer_context(self):
        return {'request': self.request}

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        return api_success(data=serializer.data, message='Posts retrieved successfully')

    def create(self, request, *args, **kwargs):
        user = request.user
        if not user.is_authenticated:
            return api_error(
                message='Authentication required',
                error_code='unauthorized',
                status_code=status.HTTP_401_UNAUTHORIZED,
            )

        category_id = self.kwargs.get('category_id')
        category = None
        if category_id and category_id != 'all':
            category = get_object_or_404(FeedCategory, id=category_id)

        content = request.data.get('content')
        if not content:
            return api_error(
                message='content is required',
                error_code='missing_content',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        post = Post.objects.create(user=user, category=category, content=content)
        serializer = PostSerializer(post, context={'request': request})
        return api_success(data=serializer.data, message='Post created successfully', status_code=status.HTTP_201_CREATED)


class CommentListCreateAPIView(ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    serializer_class = CommentSerializer

    def get_queryset(self):
        post_id = self.kwargs['post_id']
        return Comment.objects.filter(post_id=post_id).order_by('-created_at')

    def create(self, request, *args, **kwargs):
        if not request.user.is_authenticated:
            return api_error(
                message='Authentication required',
                error_code='unauthorized',
                status_code=status.HTTP_401_UNAUTHORIZED,
            )

        post_id = self.kwargs['post_id']
        post = get_object_or_404(Post, id=post_id)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(user=request.user, post=post)
        return api_success(data=serializer.data, message='Comment created successfully', status_code=status.HTTP_201_CREATED)


class ToggleLikeAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        existing_like = Like.objects.filter(post=post, user=request.user).first()

        if existing_like:
            existing_like.delete()
            return api_success(data={'status': 'unliked'}, message='Post unliked successfully')

        new_like = Like.objects.create(post=post, user=request.user)
        serializer = LikeSerializer(new_like)
        return api_success(
            data={'status': 'liked', 'like': serializer.data},
            message='Post liked successfully',
            status_code=status.HTTP_201_CREATED,
        )


class UserListAPIView(ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    serializer_class = UserSerializer

    def get_queryset(self):
        return User.objects.all()


class ToggleBookmarkAPIView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, post_id):
        post = get_object_or_404(Post, id=post_id)
        existing_bookmark = Bookmark.objects.filter(post=post, user=request.user).first()

        if existing_bookmark:
            existing_bookmark.delete()
            return api_success(data={'status': 'bookmark removed'}, message='Bookmark removed successfully')

        new_bookmark = Bookmark.objects.create(post=post, user=request.user)
        serializer = BookmarkSerializer(new_bookmark)
        return api_success(
            data={'status': 'bookmarked', 'bookmark': serializer.data},
            message='Post bookmarked successfully',
            status_code=status.HTTP_201_CREATED,
        )
