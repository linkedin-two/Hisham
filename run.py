import os
import requests

response = requests.post(
    "https://api.brevo.com/v3/smtp/email",
    headers={
        "accept": "application/json",
        "api-key": os.getenv("BREVO_API_KEY"),
        "content-type": "application/json",
    },
    json={
        "sender": {
            "name": "App",
            "email": "bobbykboseoffice@gmail.com"
        },
        "to": [
            {
                "email": "bobbykboselinkedin@gmail.com"
            }
        ],
        "subject": "Your OTP",
        "textContent": f"Your OTP is 1234eeeeeeee56",
    },
    timeout=30,
)