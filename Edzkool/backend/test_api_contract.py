import json
import time
from dataclasses import dataclass, asdict
from typing import Any

import pytest
from django.urls import URLPattern, URLResolver, get_resolver
from rest_framework import status
from rest_framework.test import APIClient
from django.contrib.auth import get_user_model

User = get_user_model()

# Helper to find all endpoints dynamically
def get_all_api_endpoints():
    def extract(urlpatterns, prefix=''):
        endpoints = []
        for pattern in urlpatterns:
            if isinstance(pattern, URLResolver):
                new_prefix = prefix + str(pattern.pattern)
                endpoints.extend(extract(pattern.url_patterns, new_prefix))
            elif isinstance(pattern, URLPattern):
                path = prefix + str(pattern.pattern)
                if not any(x in path for x in ['admin/', 'static/', 'media/', '__debug__']):
                    full_path = '/' + path.replace('^', '').replace('$', '').replace('<drf_format_suffix:format>', '')
                    # Avoid paths with regex params for generic GET test
                    if '(?P<' not in full_path and '<' not in full_path:
                        endpoints.append(full_path)
        return list(set(endpoints))
    
    resolver = get_resolver()
    return extract(resolver.url_patterns)

@pytest.fixture
def api_client():
    client = APIClient()
    client.raise_request_exception = False
    return client

@dataclass
class EndpointResult:
    url: str
    mode: str  # "anon" | "auth"
    method: str
    status: int
    duration_s: float
    content_type: str
    json_ok: bool
    failure: str | None

class TestAPIContract:
    results: list[EndpointResult] = []

    @pytest.fixture
    def authenticated_client(self, api_client, db):
        user = User.objects.create_user(username='testadmin', email='admin@example.com', password='password123')
        api_client.force_authenticate(user=user)
        return api_client

    def _try_parse_json(self, response) -> bool:
        if 'application/json' not in response.headers.get('Content-Type', ''):
            return False
        try:
            response.json()
            return True
        except Exception:
            return False

    def _record(self, *, url: str, mode: str, method: str, response, duration_s: float, failure: str | None):
        self.results.append(
            EndpointResult(
                url=url,
                mode=mode,
                method=method,
                status=int(getattr(response, 'status_code', 0) or 0),
                duration_s=float(duration_s),
                content_type=str(response.headers.get('Content-Type', '')),
                json_ok=self._try_parse_json(response),
                failure=failure,
            )
        )

    def _exercise_get(self, client: APIClient, *, url: str, mode: str):
        start = time.time()
        response = client.get(url)
        duration = time.time() - start

        status_code = int(response.status_code)
        failure = None

        # Contract invariants:
        # - never crash (500)
        # - if 200 -> must be JSON (this project is mostly DRF)
        if status_code == 500:
            # Capture a short snippet of the error payload (HTML or JSON)
            try:
                snippet = (response.content or b'')[:800].decode('utf-8', errors='replace')
            except Exception:
                snippet = '<unreadable response content>'
            failure = f"500 Internal Server Error\n{snippet}"
        elif status_code == status.HTTP_200_OK:
            if 'application/json' not in response.headers.get('Content-Type', ''):
                failure = f"200 but non-JSON Content-Type: {response.headers.get('Content-Type', '')}"
            elif not self._try_parse_json(response):
                failure = "200 but invalid JSON"

        self._record(url=url, mode=mode, method='GET', response=response, duration_s=duration, failure=failure)

        print(f"\n[AUTO-TEST][{mode}] GET {url} | Status: {status_code} | Time: {duration:.2f}s")

        # Fail the test only on true contract break (500) or 200-with-bad-json.
        if failure is not None:
            pytest.fail(f"{url} ({mode}) failed contract: {failure}")

    @pytest.mark.django_db
    @pytest.mark.parametrize("url", get_all_api_endpoints())
    def test_contract_endpoints_get(self, api_client, authenticated_client, url):
        """Contract test for all discovered *static* endpoints.

        We deliberately accept 401/403/404/405 as valid outcomes for some endpoints,
        but we fail on:
        - 500 errors
        - 200 responses that are not valid JSON
        """

        # Skip endpoints that are almost certainly not meaningful without complex payloads
        # or are OTP flows. We still want them discovered; they can be added as dedicated tests later.
        if any(x in url for x in ['otp', 'verify']):
            pytest.skip("Skipping OTP/verification flow in generic contract run")

        # Exercise as anonymous (auth behavior)
        self._exercise_get(api_client, url=url, mode='anon')

        # Exercise as authenticated
        self._exercise_get(authenticated_client, url=url, mode='auth')

    @classmethod
    def teardown_class(cls):
        """Generate a summary report."""
        print("\n\n" + "="*50)
        print("API HEALTH SUMMARY REPORT")
        print("="*50)
        failed = [r for r in cls.results if r.failure is not None]
        slow = [r for r in cls.results if r.duration_s > 0.5]
        total = len(cls.results)

        # Health score: percentage of checks that didn't violate contract invariants
        passed_count = total - len(failed)
        score = (passed_count / total * 100.0) if total else 0.0

        print(f"Total Checks (anon+auth): {total}")
        print(f"Passed Checks: {passed_count}")
        print(f"Failed Checks: {len(failed)}")
        print(f"Slow Checks (>0.5s): {len(slow)}")
        print(f"Health Score: {score:.1f}%")

        report: dict[str, Any] = {
            'total_checks': total,
            'passed_checks': passed_count,
            'failed_checks': len(failed),
            'slow_checks': len(slow),
            'health_score': score,
            'failures': [asdict(r) for r in failed],
            'slow': [asdict(r) for r in slow],
            'all': [asdict(r) for r in cls.results],
        }

        try:
            with open('api_contract_report.json', 'w', encoding='utf-8') as f:
                json.dump(report, f, indent=2)
            print("\nWrote JSON report: api_contract_report.json")
        except Exception as e:
            print(f"\nFailed to write JSON report: {e}")

        if slow:
            print("\nSlow Checks:")
            for s in slow[:30]:
                print(f"  - [{s.mode}] {s.method} {s.url} ({s.duration_s:.2f}s) status={s.status}")

        if failed:
            print("\nContract Failures:")
            for f in failed[:30]:
                print(f"  - [{f.mode}] {f.method} {f.url} status={f.status}: {f.failure.splitlines()[0]}")
        print("="*50)
