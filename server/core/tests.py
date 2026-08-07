from importlib import reload

from django.contrib.auth.models import User
from django.test import override_settings
from django.urls import clear_url_caches, set_urlconf
from rest_framework import status
from rest_framework.test import APITestCase

DOCS_PATHS = (
    "/api/schema/",
    "/api/schema/swagger-ui/",
    "/api/schema/redoc/",
)


def _reload_urlconf():
    import config.urls as urlconf

    reload(urlconf)
    clear_url_caches()
    set_urlconf(urlconf)


class AuthAndHealthTests(APITestCase):
    def test_health_public(self):
        response = self.client.get("/api/health/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["status"], "ok")

    def test_register_and_token_login(self):
        register = self.client.post(
            "/api/auth/register/",
            {"username": "alice", "password": "secret-pass"},
            format="json",
        )
        self.assertEqual(register.status_code, status.HTTP_201_CREATED)
        self.assertIn("token", register.data)
        self.assertEqual(register.data["username"], "alice")
        self.assertIn("user_id", register.data)

        login = self.client.post(
            "/api/auth/token/",
            {"username": "alice", "password": "secret-pass"},
            format="json",
        )
        self.assertEqual(login.status_code, status.HTTP_200_OK)
        self.assertEqual(login.data["token"], register.data["token"])
        self.assertEqual(login.data["username"], "alice")

    def test_token_login_bad_password(self):
        User.objects.create_user(username="bob", password="right")
        response = self.client.post(
            "/api/auth/token/",
            {"username": "bob", "password": "wrong"},
            format="json",
        )
        self.assertIn(response.status_code, (status.HTTP_400_BAD_REQUEST, status.HTTP_401_UNAUTHORIZED))

    def test_register_duplicate_username(self):
        User.objects.create_user(username="dup", password="x")
        response = self.client.post(
            "/api/auth/register/",
            {"username": "dup", "password": "y"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_register_blank_rejected(self):
        response = self.client.post(
            "/api/auth/register/",
            {"username": "", "password": ""},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


@override_settings(DEBUG=True)
class ApiDocsEnabledTests(APITestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _reload_urlconf()

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        _reload_urlconf()

    def test_docs_available_when_debug(self):
        for path in DOCS_PATHS:
            with self.subTest(path=path):
                response = self.client.get(path)
                self.assertEqual(response.status_code, status.HTTP_200_OK)


@override_settings(DEBUG=False)
class ApiDocsDisabledTests(APITestCase):
    @classmethod
    def setUpClass(cls):
        super().setUpClass()
        _reload_urlconf()

    @classmethod
    def tearDownClass(cls):
        super().tearDownClass()
        _reload_urlconf()

    def test_docs_unavailable_when_debug_false(self):
        for path in DOCS_PATHS:
            with self.subTest(path=path):
                response = self.client.get(path)
                self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
