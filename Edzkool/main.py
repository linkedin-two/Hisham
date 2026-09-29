import requests

BASE_URL = "http://localhost:8000"

ENDPOINTS = [
    "/api/v1/teacher/teacher/",
    "/api/v1/teacher/class/",
    "/api/v1/teacher/students/",
    "/api/v1/teacher/attendance/",
    "/api/v1/teacher/quizzes/",
    "/api/v1/teacher/mcq-summary/",
]

print("=" * 70)
print("Django Teacher API Endpoint Check")
print("=" * 70)

all_ok = True

for endpoint in ENDPOINTS:
    url = BASE_URL + endpoint

    try:
        response = requests.get(url, timeout=10)

        if response.status_code == 200:
            status = "OK"
        else:
            status = "FAILED"
            all_ok = False

        print(f"\n[{status}] {response.status_code}")
        print(f"URL: {url}")
        print(f"Response time: {response.elapsed.total_seconds():.3f}s")

        # Print a small portion of the response
        try:
            data = response.json()
            print(f"Response: {str(data)[:300]}")
        except ValueError:
            print(f"Response: {response.text[:300]}")

    except requests.exceptions.ConnectionError:
        print(f"\n[ERROR] Cannot connect")
        print(f"URL: {url}")
        print("Is Django running on localhost:8000?")
        all_ok = False

    except requests.exceptions.Timeout:
        print(f"\n[TIMEOUT] Server took too long")
        print(f"URL: {url}")
        all_ok = False

    except requests.exceptions.RequestException as e:
        print(f"\n[ERROR] {e}")
        print(f"URL: {url}")
        all_ok = False

print("\n" + "=" * 70)

if all_ok:
    print("RESULT: All 6 endpoints returned HTTP 200")
else:
    print("RESULT: One or more endpoints failed")

print("=" * 70)