from django.contrib import admin
from django.apps import apps
class CustomAdminSite(admin.AdminSite):
    site_header = "Edzkool Admin"
    site_title = "Edzkool Control Center"
    index_title = "Welcome to the Edzkool Administration Panel"

    def get_app_list(self, request):
        app_list = super().get_app_list(request)
        # Define the priority order for apps you want at the top
        priority = ['notes']
        # Sort by priority first, then alphabetically
        app_list.sort(key=lambda app: (priority.index(app['app_label'])
                                       if app['app_label'] in priority else len(priority),
                                       app['app_label']))
        return app_list

custom_admin_site = CustomAdminSite(name='custom_admin')

# Auto-register all models from all installed apps
for model in apps.get_models():
    try:
        custom_admin_site.register(model)
    except admin.sites.AlreadyRegistered:
        pass