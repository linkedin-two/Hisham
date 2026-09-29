from django.urls import path

from .views import (
    ChatApiRootView,
    ChatLoginView,
    ChatUserProfileView,
    ChatUsersListView,
    ChatUsersSearchView,
    ConversationStartView,
    ConversationsView,
    DeleteMessageView,
    EditMessageView,
    MarkReadView,
    MessagesView,
    SendMessageView,
)

urlpatterns = [
    path('', ChatApiRootView.as_view(), name='api_root'),
    path('auth/login', ChatLoginView.as_view(), name='login'),
    path('auth/profile', ChatUserProfileView.as_view(), name='user_profile'),
    path('users', ChatUsersListView.as_view(), name='users_list'),
    path('users/search', ChatUsersSearchView.as_view(), name='users_search'),
    path('conversations', ConversationsView.as_view(), name='conversations_get'),
    path('conversations/start', ConversationStartView.as_view(), name='conversation_start'),
    path('messages', MessagesView.as_view(), name='messages_get'),
    path('messages/<int:msg_id>/read', MarkReadView.as_view(), name='mark_read'),
    path('messages/<int:msg_id>/delete', DeleteMessageView.as_view(), name='delete_message'),
    path('messages/<int:msg_id>/edit', EditMessageView.as_view(), name='edit_message'),
    path('send', SendMessageView.as_view(), name='send_message'),
]
