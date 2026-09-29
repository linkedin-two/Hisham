from django.urls import path
from . import views

urlpatterns = [
    # API root
    path('', views.api_root, name='api_root'),
    
    # Auth endpoints
    path('auth/login', views.login, name='login'),
    path('auth/profile', views.user_profile, name='user_profile'),
    
    # User endpoints
    path('users', views.users_list, name='users_list'),
    path('users/search', views.users_search, name='users_search'),
    
    # Conversation endpoints
    path('conversations', views.conversations_get, name='conversations_get'),
    path('conversations/start', views.conversation_start, name='conversation_start'),
    
    # Message endpoints
    path('messages', views.messages_get, name='messages_get'),
    path('messages/<int:msg_id>/read', views.mark_read, name='mark_read'),
    path('messages/<int:msg_id>/delete', views.delete_message, name='delete_message'),
    path('messages/<int:msg_id>/edit', views.edit_message, name='edit_message'),
    path('send', views.send_message, name='send_message'),
]
