import os
import sys
import django
from django.urls import get_resolver, URLPattern, URLResolver

# Setup Django environment
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'edvoayge.settings')
django.setup()

def extract_endpoints(urlpatterns, prefix=''):
    endpoints = []
    for pattern in urlpatterns:
        if isinstance(pattern, URLResolver):
            new_prefix = prefix + str(pattern.pattern)
            endpoints.extend(extract_endpoints(pattern.url_patterns, new_prefix))
        elif isinstance(pattern, URLPattern):
            full_path = prefix + str(pattern.pattern)
            # Basic filtering: ignore admin, static, and internal patterns
            if not any(x in full_path for x in ['admin/', 'static/', 'media/', '__debug__']):
                # Attempt to find methods if it's a ViewSet or API view
                callback = pattern.callback
                methods = ['GET'] # Default
                
                # Check for DRF view methods
                if hasattr(callback, 'cls'):
                    view_cls = callback.cls
                    if hasattr(view_cls, 'http_method_names'):
                        methods = [m.upper() for m in view_cls.http_method_names if m != 'options' and m != 'head']
                elif hasattr(callback, 'actions'):
                    methods = [m.upper() for m in callback.actions.keys()]
                
                endpoints.append({
                    'path': '/' + full_path.replace('^', '').replace('$', ''),
                    'methods': methods,
                    'name': pattern.name or 'unnamed'
                })
    return endpoints

if __name__ == "__main__":
    resolver = get_resolver()
    all_endpoints = extract_endpoints(resolver.url_patterns)
    
    print("Detected API Endpoints:")
    grouped = {}
    for ep in all_endpoints:
        for method in ep['methods']:
            if method not in grouped:
                grouped[method] = []
            grouped[method].append(ep['path'])
    
    for method, paths in grouped.items():
        print(f"\n{method}:")
        for path in sorted(list(set(paths))):
            print(f"  - {path}")
