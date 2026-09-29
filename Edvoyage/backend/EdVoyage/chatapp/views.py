import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404, render
from django.utils import timezone
from django.conf import settings

from .models import UserSimple, Conversation, Message


def _get_or_create_user(email):
    user, _ = UserSimple.objects.get_or_create(email=email)
    return user


def conversations_get(request):
    try:
        # Use middleware current_user if available, fallback to header or param
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email') or request.GET.get('email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)

        # Get conversations where current user is user_a OR user_b
        convs_as_a = Conversation.objects.filter(user_a=current)
        convs_as_b = Conversation.objects.filter(user_b=current)

        data = []
        seen_other_emails = set()
        
        # Process conversations where current user is user_a
        for c in convs_as_a:
            # Only include if there's at least one message
            if c.messages.exists():
                last_msg = c.messages.order_by('-timestamp').first()
                last_text = last_msg.text or ''
                last_time = last_msg.timestamp.isoformat()
                unread = c.messages.filter(seen=False).exclude(sender=current).count()

                data.append({
                    'conversation_id': c.id,
                    'other_email': c.user_b.email,
                    'other_name': c.user_b.name,
                    'last_text': last_text,
                    'last_time': last_time,
                    'unread': unread,
                })
                seen_other_emails.add(c.user_b.email)
        
        # Process conversations where current user is user_b
        for c in convs_as_b:
            # Only include if there's at least one message and we haven't already added this user
            if c.messages.exists() and c.user_a.email not in seen_other_emails:
                last_msg = c.messages.order_by('-timestamp').first()
                last_text = last_msg.text or ''
                last_time = last_msg.timestamp.isoformat()
                unread = c.messages.filter(seen=False).exclude(sender=current).count()

                data.append({
                    'conversation_id': c.id,
                    'other_email': c.user_a.email,
                    'other_name': c.user_a.name,
                    'last_text': last_text,
                    'last_time': last_time,
                    'unread': unread,
                })
                seen_other_emails.add(c.user_a.email)

        # sort by last_time desc
        data.sort(key=lambda x: x['last_time'], reverse=True)

        return JsonResponse({'status': True, 'email': current.email, 'conversations': data})
    except Exception as e:
        print("ERROR /api/conversations:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def messages_get(request):
    try:
        # Use middleware current_user if available, fallback to header or param
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email') or request.GET.get('email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        other_email = request.GET.get('other_email')
        if not other_email:
            return JsonResponse({'status': False, 'error': 'other_email required'})

        other = _get_or_create_user(other_email)
        # Ensure the conversation record for current user exists (as per spec)
        conv, _ = Conversation.objects.get_or_create(user_a=current, user_b=other)

        # Also fetch the reverse conversation (where the other user may have been 'user_a')
        rev_conv = Conversation.objects.filter(user_a=other, user_b=current).first()

        # Collect messages from both conversations (if reverse exists)
        msgs = list(conv.messages.order_by('timestamp').all())
        if rev_conv:
            msgs += list(rev_conv.messages.order_by('timestamp').all())

        # sort combined messages by timestamp asc
        msgs.sort(key=lambda mm: mm.timestamp)

        results = []
        # Update seen status for messages sent to current user
        for m in msgs:
            if m.sender != current and not m.seen:
                m.seen = True
                m.save(update_fields=['seen'])

            image_url = ''
            if m.image:
                image_url = request.build_absolute_uri(m.image.url)

            results.append({
                'id': m.id,
                'sender': m.sender.email,
                'text': m.text or '',
                'image_url': image_url,
                'timestamp': m.timestamp.isoformat(),
                'delivered': m.delivered,
                'seen': m.seen,
            })

        return JsonResponse({'status': True, 'conversation_id': conv.id, 'messages': results})
    except Exception as e:
        print("ERROR /api/messages:", e)
        return JsonResponse({'status': False, 'error': str(e)})


@csrf_exempt
def send_message(request):
    try:
        if request.method != 'POST':
            return JsonResponse({'status': False, 'error': 'POST required'})
        # Read from_email from header first, then POST params
        from_email = request.headers.get('X-User-Email') or request.POST.get('from_email') or request.POST.get('from') or request.POST.get('fromEmail')
        if not from_email:
            return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
        to_email = request.POST.get('to_email') or request.POST.get('to') or request.POST.get('toEmail')
        text = request.POST.get('text', '')
        image = request.FILES.get('image')

        if not from_email or not to_email:
            return JsonResponse({'status': False, 'error': 'from_email and to_email required'})

        sender = _get_or_create_user(from_email)
        recipient = _get_or_create_user(to_email)

        conv, _ = Conversation.objects.get_or_create(user_a=sender, user_b=recipient)

        msg = Message(conversation=conv, sender=sender, text=text, delivered=True)
        if image:
            msg.image = image
        msg.save()

        image_url = ''
        if msg.image:
            image_url = request.build_absolute_uri(msg.image.url)

        res = {
            'id': msg.id,
            'conversation_id': conv.id,
            'sender': sender.email,
            'text': msg.text or '',
            'image_url': image_url,
            'timestamp': msg.timestamp.isoformat(),
            'delivered': msg.delivered,
            'seen': msg.seen,
        }

        return JsonResponse({'status': True, 'message': res})
    except Exception as e:
        print("ERROR /api/send:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def users_list(request):
    try:
        email = request.GET.get('email') or request.headers.get('X-User-Email')
        if not email:
            return JsonResponse({'status': False, 'error': 'Authentication required. Please provide email or X-User-Email header.'})
        current = _get_or_create_user(email)
        
        # Get all users except current user
        all_users = UserSimple.objects.exclude(id=current.id).order_by('email')
        
        users = []
        for u in all_users:
            users.append({
                'email': u.email,
                'name': u.name or '',
            })
        
        return JsonResponse({'status': True, 'users': users})
    except Exception as e:
        print("ERROR /api/users:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def api_root(request):
    """API root endpoint listing available endpoints"""
    return JsonResponse({
        'status': True,
        'message': 'Chat API - Use Flutter or mobile app',
        'endpoints': {
            'auth': {
                'login': 'POST /api/auth/login',
                'profile': 'GET/POST /api/auth/profile',
            },
            'users': {
                'list': 'GET /api/users',
                'search': 'GET /api/users/search?q={query}',
            },
            'conversations': {
                'list': 'GET /api/conversations',
                'start': 'POST /api/conversations/start',
            },
            'messages': {
                'get': 'GET /api/messages?other_email={email}',
                'send': 'POST /api/send',
                'read': 'POST /api/messages/{id}/read',
                'delete': 'POST /api/messages/{id}/delete',
                'edit': 'POST /api/messages/{id}/edit',
            }
        }
    })


def users_search(request):
    """Search users by name (live search) - case-insensitive prefix matching"""
    try:
        # Use middleware current_user if available, fallback to header
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email') or request.GET.get('email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        query = request.GET.get('q', '').strip().lower()
        if not query:
            return JsonResponse({'status': True, 'users': []})
        
        # Case-insensitive search on name starting with query
        users_qs = UserSimple.objects.filter(name__istartswith=query).exclude(id=current.id)
        
        users = []
        for u in users_qs:
            users.append({
                'email': u.email,
                'name': u.name or '',
                'avatar': u.avatar or '',
                'role': u.role or '',
            })
        
        return JsonResponse({'status': True, 'users': users})
    except Exception as e:
        print("ERROR /api/users/search:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def user_profile(request):
    """Get or update current user profile"""
    try:
        # Use middleware current_user if available
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email') or request.GET.get('email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        if request.method == 'GET':
            return JsonResponse({
                'status': True,
                'user': {
                    'email': current.email,
                    'name': current.name or '',
                    'avatar': current.avatar or '',
                    'role': current.role or '',
                }
            })
        
        elif request.method == 'POST':
            name = request.POST.get('name', '').strip()
            avatar = request.POST.get('avatar', '').strip()
            role = request.POST.get('role', '').strip()
            
            if name:
                current.name = name
            if avatar:
                current.avatar = avatar
            if role:
                current.role = role
            current.save()
            
            return JsonResponse({
                'status': True,
                'user': {
                    'email': current.email,
                    'name': current.name,
                    'avatar': current.avatar,
                    'role': current.role,
                }
            })
        
        return JsonResponse({'status': False, 'error': 'GET or POST required'})
    except Exception as e:
        print("ERROR /api/auth/profile:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def login(request):
    """Login/authenticate with email - returns user profile"""
    try:
        if request.method != 'POST':
            return JsonResponse({'status': False, 'error': 'POST required'})
        
        email = request.POST.get('email') or request.headers.get('X-User-Email')
        if not email:
            return JsonResponse({'status': False, 'error': 'email required'})
        
        user = _get_or_create_user(email)
        
        return JsonResponse({
            'status': True,
            'user': {
                'email': user.email,
                'name': user.name or '',
                'avatar': user.avatar or '',
                'role': user.role or '',
            }
        })
    except Exception as e:
        print("ERROR /api/auth/login:", e)
        return JsonResponse({'status': False, 'error': str(e)})


def conversation_start(request):
    """Start a new conversation with another user"""
    try:
        if request.method != 'POST':
            return JsonResponse({'status': False, 'error': 'POST required'})
        
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email') or request.POST.get('email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        other_email = request.POST.get('other_email')
        if not other_email:
            return JsonResponse({'status': False, 'error': 'other_email required'})
        
        other = _get_or_create_user(other_email)
        
        # Get or create conversation (current as user_a)
        conv, created = Conversation.objects.get_or_create(user_a=current, user_b=other)
        
        return JsonResponse({
            'status': True,
            'conversation_id': conv.id,
            'other_email': other.email,
            'other_name': other.name or '',
            'created': created,
        })
    except Exception as e:
        print("ERROR /api/conversations/start:", e)
        return JsonResponse({'status': False, 'error': str(e)})


@csrf_exempt
def mark_read(request, msg_id):
    """Mark a specific message as read"""
    try:
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return JsonResponse({'status': False, 'error': 'message not found'})
        
        if msg.sender != current and not msg.seen:
            msg.seen = True
            msg.save(update_fields=['seen'])
        
        return JsonResponse({'status': True, 'message_id': msg_id, 'seen': True})
    except Exception as e:
        print("ERROR /api/messages/read:", e)
        return JsonResponse({'status': False, 'error': str(e)})


@csrf_exempt
def delete_message(request, msg_id):
    """Soft delete a message (only sender can delete)"""
    try:
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return JsonResponse({'status': False, 'error': 'message not found'})
        
        if msg.sender != current:
            return JsonResponse({'status': False, 'error': 'cannot delete others messages'})
        
        msg.is_deleted = True
        msg.save(update_fields=['is_deleted'])
        
        return JsonResponse({'status': True, 'message_id': msg_id, 'deleted': True})
    except Exception as e:
        print("ERROR /api/messages/delete:", e)
        return JsonResponse({'status': False, 'error': str(e)})


@csrf_exempt
def edit_message(request, msg_id):
    """Edit a message text (only sender can edit)"""
    try:
        if request.method != 'POST':
            return JsonResponse({'status': False, 'error': 'POST required'})
        
        current = getattr(request, 'current_user', None)
        if not current:
            email = request.headers.get('X-User-Email')
            if not email:
                return JsonResponse({'status': False, 'error': 'Authentication required. Please provide X-User-Email header.'})
            current = _get_or_create_user(email)
        
        msg = Message.objects.filter(id=msg_id).first()
        if not msg:
            return JsonResponse({'status': False, 'error': 'message not found'})
        
        if msg.sender != current:
            return JsonResponse({'status': False, 'error': 'cannot edit others messages'})
        
        new_text = request.POST.get('text', '').strip()
        if not new_text:
            return JsonResponse({'status': False, 'error': 'text required'})
        
        msg.text = new_text
        msg.is_edited = True
        msg.edited_at = timezone.now()
        msg.save()
        
        return JsonResponse({
            'status': True,
            'message': {
                'id': msg.id,
                'text': msg.text,
                'is_edited': msg.is_edited,
                'edited_at': msg.edited_at.isoformat(),
            }
        })
    except Exception as e:
        print("ERROR /api/messages/edit:", e)
        return JsonResponse({'status': False, 'error': str(e)})
