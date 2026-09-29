"""Chat API — Django REST Framework views with JWT authentication."""

import logging

from django.utils import timezone
from rest_framework import status
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from edvoayge.auth_utils import get_user_email
from edvoayge.storage_utils import get_file_access_url

from .models import Conversation, Message, UserSimple

logger = logging.getLogger(__name__)


def _get_or_create_chat_user(email):
    user, _ = UserSimple.objects.get_or_create(email=email.lower())
    return user


def _chat_user_from_request(request):
    email = get_user_email(request.user)
    if not email:
        return None
    return _get_or_create_chat_user(email)


class ChatApiRootView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        return Response({
            'status': True,
            'message': 'Chat API — JWT Bearer token required',
            'endpoints': {
                'users': {'list': 'GET /api/users'},
                'conversations': {'list': 'GET /api/conversations', 'start': 'POST /api/conversations/start'},
                'messages': {
                    'get': 'GET /api/messages?other_email={email}',
                    'send': 'POST /api/send',
                },
            },
        })


class ConversationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response(
                    {'status': False, 'error': 'Authenticated user has no email'},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            data = []
            seen_other_emails = set()

            for c in Conversation.objects.filter(user_a=current):
                if c.messages.exists():
                    last_msg = c.messages.order_by('-timestamp').first()
                    data.append({
                        'conversation_id': c.id,
                        'other_email': c.user_b.email,
                        'other_name': c.user_b.name,
                        'last_text': last_msg.text or '',
                        'last_time': last_msg.timestamp.isoformat(),
                        'unread': c.messages.filter(seen=False).exclude(sender=current).count(),
                    })
                    seen_other_emails.add(c.user_b.email)

            for c in Conversation.objects.filter(user_b=current):
                if c.messages.exists() and c.user_a.email not in seen_other_emails:
                    last_msg = c.messages.order_by('-timestamp').first()
                    data.append({
                        'conversation_id': c.id,
                        'other_email': c.user_a.email,
                        'other_name': c.user_a.name,
                        'last_text': last_msg.text or '',
                        'last_time': last_msg.timestamp.isoformat(),
                        'unread': c.messages.filter(seen=False).exclude(sender=current).count(),
                    })

            data.sort(key=lambda x: x['last_time'], reverse=True)
            return Response({'status': True, 'email': current.email, 'conversations': data})
        except Exception:
            logger.exception('Error listing conversations')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class MessagesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

            other_email = request.query_params.get('other_email')
            if not other_email:
                return Response({'status': False, 'error': 'other_email required'}, status=400)

            other = _get_or_create_chat_user(other_email)
            conv, _ = Conversation.objects.get_or_create(user_a=current, user_b=other)
            rev_conv = Conversation.objects.filter(user_a=other, user_b=current).first()

            msgs = list(conv.messages.order_by('timestamp'))
            if rev_conv:
                msgs += list(rev_conv.messages.order_by('timestamp'))
            msgs.sort(key=lambda m: m.timestamp)

            results = []
            for m in msgs:
                if m.sender != current and not m.seen:
                    m.seen = True
                    m.save(update_fields=['seen'])
                results.append({
                    'id': m.id,
                    'sender': m.sender.email,
                    'text': m.text or '',
                    'image_url': get_file_access_url(m.image, request) if m.image else '',
                    'timestamp': m.timestamp.isoformat(),
                    'delivered': m.delivered,
                    'seen': m.seen,
                })

            return Response({'status': True, 'conversation_id': conv.id, 'messages': results})
        except Exception:
            logger.exception('Error listing messages')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class SendMessageView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

            to_email = (
                request.data.get('to_email')
                or request.data.get('to')
                or request.data.get('toEmail')
            )
            text = request.data.get('text', '')
            image = request.FILES.get('image')

            if not to_email:
                return Response({'status': False, 'error': 'to_email required'}, status=400)

            recipient = _get_or_create_chat_user(to_email)
            conv, _ = Conversation.objects.get_or_create(user_a=current, user_b=recipient)

            msg = Message(conversation=conv, sender=current, text=text, delivered=True)
            if image:
                msg.image = image
            msg.save()

            return Response({
                'status': True,
                'message': {
                    'id': msg.id,
                    'conversation_id': conv.id,
                    'sender': current.email,
                    'text': msg.text or '',
                    'image_url': get_file_access_url(msg.image, request) if msg.image else '',
                    'timestamp': msg.timestamp.isoformat(),
                    'delivered': msg.delivered,
                    'seen': msg.seen,
                },
            })
        except Exception:
            logger.exception('Error sending message')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class ChatUsersListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

            users = [
                {'email': u.email, 'name': u.name or ''}
                for u in UserSimple.objects.exclude(id=current.id).order_by('email')
            ]
            return Response({'status': True, 'users': users})
        except Exception:
            logger.exception('Error listing chat users')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class ChatUsersSearchView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

            query = request.query_params.get('q', '').strip().lower()
            if not query:
                return Response({'status': True, 'users': []})

            users = [
                {
                    'email': u.email,
                    'name': u.name or '',
                    'avatar': u.avatar or '',
                    'role': u.role or '',
                }
                for u in UserSimple.objects.filter(name__istartswith=query).exclude(id=current.id)
            ]
            return Response({'status': True, 'users': users})
        except Exception:
            logger.exception('Error searching chat users')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class ChatUserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get(self, request):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)
        return Response({
            'status': True,
            'user': {
                'email': current.email,
                'name': current.name or '',
                'avatar': current.avatar or '',
                'role': current.role or '',
            },
        })

    def post(self, request):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

        name = request.data.get('name', '').strip()
        avatar = request.data.get('avatar', '').strip()
        role = request.data.get('role', '').strip()
        if name:
            current.name = name
        if avatar:
            current.avatar = avatar
        if role:
            current.role = role
        current.save()

        return Response({
            'status': True,
            'user': {
                'email': current.email,
                'name': current.name,
                'avatar': current.avatar,
                'role': current.role,
            },
        })


class ChatLoginView(APIView):
    """Deprecated — validates JWT and returns chat user profile."""
    permission_classes = [IsAuthenticated]

    def post(self, request):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)
        return Response({
            'status': True,
            'user': {
                'email': current.email,
                'name': current.name or '',
                'avatar': current.avatar or '',
                'role': current.role or '',
            },
        })


class ConversationStartView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        try:
            current = _chat_user_from_request(request)
            if not current:
                return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

            other_email = request.data.get('other_email')
            if not other_email:
                return Response({'status': False, 'error': 'other_email required'}, status=400)

            other = _get_or_create_chat_user(other_email)
            conv, created = Conversation.objects.get_or_create(user_a=current, user_b=other)
            return Response({
                'status': True,
                'conversation_id': conv.id,
                'other_email': other.email,
                'other_name': other.name or '',
                'created': created,
            })
        except Exception:
            logger.exception('Error starting conversation')
            return Response({'status': False, 'error': 'Internal server error'}, status=500)


class MarkReadView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, msg_id):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return Response({'status': False, 'error': 'message not found'}, status=404)

        if msg.sender != current and not msg.seen:
            msg.seen = True
            msg.save(update_fields=['seen'])

        return Response({'status': True, 'message_id': msg_id, 'seen': True})


class DeleteMessageView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, msg_id):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return Response({'status': False, 'error': 'message not found'}, status=404)
        if msg.sender != current:
            return Response({'status': False, 'error': 'cannot delete others messages'}, status=403)

        msg.is_deleted = True
        msg.save(update_fields=['is_deleted'])
        return Response({'status': True, 'message_id': msg_id, 'deleted': True})


class EditMessageView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request, msg_id):
        current = _chat_user_from_request(request)
        if not current:
            return Response({'status': False, 'error': 'Authenticated user has no email'}, status=400)

        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return Response({'status': False, 'error': 'message not found'}, status=404)
        if msg.sender != current:
            return Response({'status': False, 'error': 'cannot edit others messages'}, status=403)

        new_text = (request.data.get('text') or '').strip()
        if not new_text:
            return Response({'status': False, 'error': 'text required'}, status=400)

        msg.text = new_text
        msg.is_edited = True
        msg.edited_at = timezone.now()
        msg.save()

        return Response({
            'status': True,
            'message': {
                'id': msg.id,
                'text': msg.text,
                'is_edited': msg.is_edited,
                'edited_at': msg.edited_at.isoformat(),
            },
        })
