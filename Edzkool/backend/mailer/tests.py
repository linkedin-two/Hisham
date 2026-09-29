from django.test import TestCase, Client


class MailerAPITest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_root_health_check(self):
        response = self.client.get('/health')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_send_otp_api(self):
        response = self.client.post(
            '/api/v1/send-otp/',
            data={'email': 'bobbykboseoffice@gmail.com'},
            content_type='application/json'
        )
        self.assertEqual(response.status_code, 201)
        self.assertTrue(response.json()['success'])
        self.assertEqual(response.json()['data']['contact'], 'bobbykboseoffice@gmail.com')
