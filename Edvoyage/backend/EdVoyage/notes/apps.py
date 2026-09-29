import sys
from django.apps import AppConfig
from django.db.models.signals import post_migrate


def _run_auto_media_organizer(sender, **kwargs):
    try:
        from .services.media_organizer import auto_organize_legacy_media
        auto_organize_legacy_media()
    except Exception:
        pass


class ApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'notes'

    def ready(self):
        post_migrate.connect(_run_auto_media_organizer, sender=self)
