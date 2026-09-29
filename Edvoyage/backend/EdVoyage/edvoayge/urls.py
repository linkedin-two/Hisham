"""
URL configuration for edvoayge project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse
from django.conf import settings
from django.conf.urls.static import static
from .admin import custom_admin_site


def app_config(request):
    return JsonResponse({'developer_mode': settings.DEVELOPER_MODE})


def health_check(request):
    """Lightweight 200 health check endpoint for uptime monitors and keep-alive cron jobs."""
    return JsonResponse({'status': 'ok', 'message': 'EdVoyage API is healthy'}, status=200)


urlpatterns = [
    path('health/', health_check, name='health_check'),
    path('health', health_check),
    path('admin/', custom_admin_site.urls),
    path('api/v1/', include([
        path('health/', health_check),
        path('health', health_check),
        path('config/', app_config),
        path('users/', include('users.urls')),
        path('universities/', include('universities.urls')),
        # Frontend compatibility - singular 'university' prefix
        path('university/', include('universities.urls')),
        path('courses/', include('courses.urls')),
        path('applications/', include('applications.urls')),
        path('notifications/', include('notifications.urls')),
        path('bookmarks/', include('bookmarks.urls')),
        path('payments/', include('payments.urls')),
        path('quizzes/', include('quizzes.urls')),
        path('content/', include('content.urls')),
      
        path('study-abroad/', include('study_abroad.urls')),
        path('simple-education/', include('simple_education.urls')),
        path('cavity/', include('cavity.urls')),
        path('feed/', include('feed.urls')),
        path('notes/', include('notes.urls')),
    ])),
    # Chat API endpoints (Flutter expects /api/ not /api/v1/)
    path('api/', include('chatapp.urls')),
]

# Serve static & media files
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
else:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
