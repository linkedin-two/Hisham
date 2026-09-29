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
from django.urls import path, include, re_path
from django.http import JsonResponse, FileResponse, Http404
from django.conf import settings
from django.conf.urls.static import static
from .admin import custom_admin_site
import os
import mimetypes


def app_config(request):
    return JsonResponse({'developer_mode': settings.DEVELOPER_MODE})


def _safe_media_path(path):
    """Resolve media path and block directory traversal."""
    media_root = os.path.realpath(str(settings.MEDIA_ROOT))
    file_path = os.path.realpath(os.path.join(media_root, path))
    if not file_path.startswith(media_root + os.sep) and file_path != media_root:
        raise Http404('Invalid media path')
    return file_path


def serve_media_with_cors(request, path):
    """Serve media files with CORS headers and HTTP Range support for video seeking."""
    if not settings.MEDIA_ROOT:
        raise Http404('Media not available')

    file_path = _safe_media_path(path)

    if not (os.path.exists(file_path) and os.path.isfile(file_path)):
        return JsonResponse({'error': 'File not found'}, status=404)

    content_type, _ = mimetypes.guess_type(file_path)
    if content_type is None:
        content_type = 'application/octet-stream'

    file_size = os.path.getsize(file_path)
    range_header = request.META.get('HTTP_RANGE', '').strip()

    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Range, Content-Type",
        "Access-Control-Expose-Headers": "Content-Range, Accept-Ranges, Content-Length",
        "Accept-Ranges": "bytes",
    }

    # Handle preflight OPTIONS
    if request.method == 'OPTIONS':
        response = JsonResponse({}, status=204)
        for k, v in cors_headers.items():
            response[k] = v
        return response

    if range_header and range_header.startswith('bytes='):
        # Parse the Range header
        try:
            range_spec = range_header[6:]  # strip "bytes="
            start_str, end_str = range_spec.split('-')
            start = int(start_str) if start_str else 0
            end = int(end_str) if end_str else file_size - 1
        except (ValueError, IndexError):
            start, end = 0, file_size - 1

        # Clamp values
        start = max(0, start)
        end = min(end, file_size - 1)
        length = end - start + 1

        f = open(file_path, 'rb')
        f.seek(start)

        response = FileResponse(
            f,
            content_type=content_type,
            status=206,
        )
        response['Content-Length'] = str(length)
        response['Content-Range'] = f'bytes {start}-{end}/{file_size}'
    else:
        response = FileResponse(open(file_path, 'rb'), content_type=content_type)
        response['Content-Length'] = str(file_size)

    for k, v in cors_headers.items():
        response[k] = v

    return response


def health_check(request):
    return JsonResponse({'status': 'ok', 'message': 'Backend service is running'}, status=200)


urlpatterns = [
    path('', health_check, name='root-health'),
    path('health', health_check, name='health-no-slash'),
    path('health/', health_check, name='health-slash'),
    path(f'{settings.ADMIN_URL.rstrip("/")}/', custom_admin_site.urls),
    path('api/v1/', include([
        path('health', health_check, name='api-health-no-slash'),
        path('health/', health_check, name='api-health-slash'),
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
        path('notes/', include('notes.urls')),
        path('simple-education/', include('simple_education.urls')),
        path('cavity/', include('cavity.urls')),
        path('feed/', include('feed.urls')),
        path('google-meet/', include('google_meet.urls')),
        path('teacher/', include('teacher_cms.urls')),
        path('mailer/', include('mailer.urls')),
        path('', include('mailer.urls')),
    ])),
    # Chat API endpoints (Flutter expects /api/ not /api/v1/)
    path('api/', include('chatapp.urls')),
    # Serve media files with CORS headers (production + development)
    re_path(r'^media/(?P<path>.*)$', serve_media_with_cors),
]

# Serve static files in development
if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
