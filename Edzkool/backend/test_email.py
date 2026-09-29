import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'edvoayge.settings')
django.setup()

from users.services import EmailService
success = EmailService.test_email_connection()
print("Success:", success)
