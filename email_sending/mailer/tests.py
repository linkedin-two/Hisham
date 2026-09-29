from django.test import TestCase, Client

class HealthCheckAPITest(TestCase):
    def setUp(self):
        self.client = Client()

    def test_root_health_check(self):
        response = self.client.get('/', HTTP_HOST='hisham-final-submission.onrender.com')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_health_check_endpoint(self):
        response = self.client.get('/health', HTTP_HOST='hisham-final-submission.onrender.com')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_health_check_slash_endpoint(self):
        response = self.client.get('/health/', HTTP_HOST='hisham-final-submission.onrender.com')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_api_v1_health_check(self):
        response = self.client.get('/api/v1/health/', HTTP_HOST='hisham-final-submission.onrender.com')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')

    def test_post_health_with_email(self):
        response = self.client.post(
            '/health',
            data={'email': 'bobbykboseoffice@gmail.com'},
            content_type='application/json',
            HTTP_HOST='hisham-final-submission.onrender.com'
        )
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()['success'])
        self.assertEqual(response.json()['data']['contact'], 'bobbykboseoffice@gmail.com')

    def test_post_health_without_email(self):
        response = self.client.post(
            '/health',
            content_type='application/json',
            HTTP_HOST='hisham-final-submission.onrender.com'
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['status'], 'ok')
