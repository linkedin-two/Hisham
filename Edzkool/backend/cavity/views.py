from rest_framework.exceptions import ValidationError
from rest_framework import viewsets, status, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from edvoayge.api_response import api_success, api_error
from django.db.models import Q, Count
from django.utils import timezone
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from datetime import datetime, timedelta
import logging
from django.contrib.auth import get_user_model
# Set up logging
logger = logging.getLogger(__name__)

from .models import (
    User, Post, PostLike, Comment, CommentLike, 
    PostShare, Notification, UserFollow
)
from .serializers import (
   UserSerializer, UserMinimalSerializer, PostSerializer, PostCreateSerializer,
    CommentSerializer,  PostLikeSerializer,
    CommentLikeSerializer, PostShareSerializer, NotificationSerializer,
    UserFollowSerializer, PostLikeCreateSerializer, CommentLikeCreateSerializer,
    PostShareCreateSerializer
)


class UserViewSet(viewsets.ModelViewSet):
    """ViewSet for User management"""
    queryset = User.objects.filter(is_active=True)
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]


    def get_queryset(self):
        queryset = super().get_queryset()
        # Exclude current user from search results
        if self.action == 'list':
            queryset = queryset.exclude(id=self.request.user.id)
        return queryset

    @action(detail=False, methods=['get'])
    def my_posts(self, request):
        """Get posts of the current authenticated user"""
        user = request.user
        posts = Post.objects.filter(author=user).order_by('-created_at')
        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response(serializer.data)


    @action(detail=True, methods=['get'])
    def likes(self, request, pk=None):
        """Get posts liked by user"""
        user = self.get_object()
        liked_posts = Post.objects.filter(
            likes__user=user
        ).order_by('-created_at')
        serializer = PostSerializer(liked_posts, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['post', 'delete'])
    def follow(self, request, pk=None):
        """Follow/unfollow a user"""
        user_to_follow = self.get_object()
        current_user = request.user

        if request.method == 'POST':
            # Follow user
            follow, created = UserFollow.objects.get_or_create(
                follower=current_user,
                following=user_to_follow
            )
            if created:
                # Create notification
                Notification.objects.create(
                    recipient=user_to_follow,
                    sender=current_user,
                    notification_type='follow',
                    message=f"{current_user.username} started following you"
                )
            return api_success({'message': 'User followed successfully'}, status_code=status.HTTP_201_CREATED)
        
        elif request.method == 'DELETE':
            # Unfollow user
            UserFollow.objects.filter(
                follower=current_user,
                following=user_to_follow
            ).delete()
            return api_success({'message': 'User unfollowed successfully'})

    @action(detail=False, methods=['get'])
    def profile(self, request):
        """Get current user profile"""
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=['put', 'patch'])
    def update_profile(self, request):
        """Update current user profile"""
        serializer = self.get_serializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return api_success(serializer.data, message="Profile updated successfully")
        return api_error(
            serializer.errors, 
            error_code="validation_error",
            status_code=status.HTTP_400_BAD_REQUEST
        )


class PostViewSet(viewsets.ModelViewSet):
    """ViewSet for Post management"""
    queryset = Post.objects.all().order_by('-created_at')
    serializer_class = PostSerializer
    permission_classes = [permissions.IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['author', 'year', 'is_anonymous', 'is_edited']
    search_fields = ['content']

    def get_serializer_class(self):
        if self.action == 'create':
            return PostCreateSerializer
        return PostSerializer

    def get_queryset(self):
        
        
        queryset = super().get_queryset()
        
        # Filter by year if provided
        year = self.request.query_params.get('year', None)
        if year:
            queryset = queryset.filter(year=year)
        
        return queryset

    def create(self, request, *args, **kwargs):
        
        try:
            # Get the appropriate serializer
            serializer_class = self.get_serializer_class()
            
            # Create serializer with request data
            serializer = serializer_class(data=request.data)
            
            # Validate the data
            if serializer.is_valid():
                
                # Save the post
                post = serializer.save()
                
                # Return response
                response_data = PostSerializer(post, context={'request': request}).data
                
                return Response(response_data, status=status.HTTP_201_CREATED)
            else:
                return api_error(
            serializer.errors, 
            error_code="validation_error",
            status_code=status.HTTP_400_BAD_REQUEST
        )
                
        except Exception as e:
            import traceback
            return Response(
                {'error': f'Internal server error: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    def perform_create(self, serializer):
        
        # The serializer now handles author assignment
        # Just save the post - author is already assigned in serializer
        post = serializer.save()

    def perform_update(self, serializer):
        # Track edit history
        instance = serializer.instance
        if instance.content != serializer.validated_data.get('content', instance.content):
            edit_history = instance.edit_history or []
            edit_history.append({
                'content': instance.content,
                'edited_at': timezone.now().isoformat()
            })
            serializer.save(edit_history=edit_history, is_edited=True)
        else:
            serializer.save()

    @action(detail=True, methods=['get'])
    def comments(self, request, pk=None):
        """Get comments for a post"""
        post = self.get_object()
        comments = Comment.objects.filter(
            post=post, 
            parent_comment=None
        ).order_by('created_at')
        serializer = CommentSerializer(comments, many=True, context={'request': request})
        return Response(serializer.data)

    @action(detail=True, methods=['get'])
    def likes(self, request, pk=None):
        """Get likes for a post"""
        post = self.get_object()
        likes = PostLike.objects.filter(post=post).order_by('-created_at')
        serializer = PostLikeSerializer(likes, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post', 'delete'])
    def like(self, request, pk=None):
        """Like/unlike a post"""
        try:
            
            post = self.get_object()
            
            # Check if user is authenticated
            if not request.user.is_authenticated:
                return Response(
                    {'error': 'Authentication required'}, 
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            user = request.user

            if request.method == 'POST':
                
                # Check if user already liked this post
                existing_like = PostLike.objects.filter(user=user, post=post).first()
                if existing_like:
                    return Response({
                        'message': 'Post already liked',
                        'like_count': post.like_count,
                        'is_liked': True
                    }, status=status.HTTP_200_OK)
                
                # Like post - create if doesn't exist
                like, created = PostLike.objects.get_or_create(
                    user=user,
                    post=post
                )
                
                # Refresh the post object to get updated like count
                post.refresh_from_db()
                
                if created:
                    
                    # Create notification
                    if user != post.author:
                        notification = Notification.objects.create(
                            recipient=post.author,
                            sender=user,
                            notification_type='like',
                            post=post,
                            message=f"{user.username} liked your post"
                        )
                
                return Response({
                    'message': 'Post liked successfully',
                    'like_count': post.like_count,
                    'is_liked': True
                }, status=status.HTTP_201_CREATED)
            
            elif request.method == 'DELETE':
                
                # Unlike post - delete the like
                deleted_count, _ = PostLike.objects.filter(user=user, post=post).delete()
                
                # Refresh the post object to get updated like count
                post.refresh_from_db()
                
                return Response({
                    'message': 'Post unliked successfully',
                    'like_count': post.like_count,
                    'is_liked': False
                }, status=status.HTTP_200_OK)
                
        except Exception as e:
            import traceback
            return Response(
                {'error': f'Internal server error: {str(e)}'}, 
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

    @action(detail=True, methods=['post'])
    def share(self, request, pk=None):
        """Share a post"""
        post = self.get_object()
        serializer = PostShareCreateSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            serializer.save()
            
            # Create notification
            if request.user != post.author:
                Notification.objects.create(
                    recipient=post.author,
                    sender=request.user,
                    notification_type='share',
                    post=post,
                    message=f"{request.user.username} shared your post"
                )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return api_error(
            serializer.errors, 
            error_code="validation_error",
            status_code=status.HTTP_400_BAD_REQUEST
        )



User = get_user_model()
from rest_framework import generics

class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.all()
    serializer_class = CommentSerializer

    def get_serializer_class(self):
        if self.action == 'create_comment':
            return CommentSerializer
        return CommentSerializer

    @action(detail=False, methods=['post'], url_path='create')
    def create_comment(self, request):
        






        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            comment = serializer.save()
            return Response(
                CommentSerializer(comment).data,
                status=status.HTTP_201_CREATED
            )
        return api_error(
            serializer.errors, 
            error_code="validation_error",
            status_code=status.HTTP_400_BAD_REQUEST
        )

class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for Notification management"""
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(recipient=self.request.user).order_by('-created_at')

    @action(detail=True, methods=['put', 'patch'])
    def read(self, request, pk=None):
        """Mark notification as read"""
        notification = self.get_object()
        notification.is_read = True
        notification.save()
        return Response({'message': 'Notification marked as read'})

    @action(detail=False, methods=['put'])
    def read_all(self, request):
        """Mark all notifications as read"""
        Notification.objects.filter(recipient=request.user, is_read=False).update(is_read=True)
        return Response({'message': 'All notifications marked as read'})

    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """Get count of unread notifications"""
        count = Notification.objects.filter(recipient=request.user, is_read=False).count()
        return Response({'unread_count': count})


class SearchViewSet(viewsets.ViewSet):
    """ViewSet for search functionality"""
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=['get'])
    def posts(self, request):
        """Search posts"""
        query = request.query_params.get('q', '')
        if not query:
            return Response({'results': []})
        
        posts = Post.objects.filter(
            Q(content__icontains=query) | Q(author__username__icontains=query)
        ).order_by('-created_at')
        
        serializer = PostSerializer(posts, many=True, context={'request': request})
        return Response({'results': serializer.data})

    @action(detail=False, methods=['get'])
    def users(self, request):
        """Search users"""
        query = request.query_params.get('q', '')
        if not query:
            return Response({'results': []})
        
        users = User.objects.filter(
            Q(username__icontains=query) | 
            Q(first_name__icontains=query) | 
            Q(last_name__icontains=query) |
            Q(year_tag__icontains=query),
            is_active=True
        ).exclude(id=request.user.id)
        
        serializer = UserMinimalSerializer(users, many=True)
        return Response({'results': serializer.data})
