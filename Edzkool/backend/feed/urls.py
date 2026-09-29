from django.urls import path
from .views import (
    PostListCreateAPIView,
    CommentListCreateAPIView,
    ToggleLikeAPIView,
    UserListAPIView,
    ToggleBookmarkAPIView,
    FeedCategoryView,
)

urlpatterns = [
    path("posts/comments/<int:post_id>/", CommentListCreateAPIView.as_view(), name="post-comments"),
    path("posts/<str:category_id>/", PostListCreateAPIView.as_view(), name="posts"),
    path("posts/toggle-like/<int:post_id>/", ToggleLikeAPIView.as_view()),
    path("posts/toggle-bookmark/<int:post_id>/", ToggleBookmarkAPIView.as_view()),
    path("users/", UserListAPIView.as_view(), name="user"),
    path("categories/", FeedCategoryView.as_view(), name="categories"),
]

