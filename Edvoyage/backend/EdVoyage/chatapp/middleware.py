from .models import UserSimple


class EmailAuthMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Get email from header
        email = request.headers.get('X-User-Email')
        
        if email:
            # Case-insensitive lookup
            try:
                user = UserSimple.objects.get(email__iexact=email)
            except UserSimple.DoesNotExist:
                # Create user with defaults if not exists
                user = UserSimple.objects.create(
                    email=email.lower(),
                    name='',
                    role='',
                    avatar=''
                )
            request.current_user = user
        else:
            request.current_user = None
        
        response = self.get_response(request)
        return response
