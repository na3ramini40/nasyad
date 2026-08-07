from datetime import timedelta
from unittest.mock import patch

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from accounts.models import DeviceRegistration, PhoneOtp, UserProfile
from accounts.services import COOLDOWN_SECONDS


@override_settings(DEBUG=True)
class AccountsOtpAndProfileTests(APITestCase):
    phone = "+989121234567"
    code = "123456"

    def _request_otp(self, phone=None, code=None):
        phone = phone or self.phone
        code = code or self.code
        with patch("accounts.views.generate_otp_code", return_value=code):
            return self.client.post(
                "/api/accounts/otp/request/",
                {"phone": phone},
                format="json",
            )

    def _verify(self, phone=None, code=None):
        return self.client.post(
            "/api/accounts/otp/verify/",
            {"phone": phone or self.phone, "code": code or self.code},
            format="json",
        )

    def _auth(self, token_key: str):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token_key}")

    def test_request_otp_returns_cooldown_payload(self):
        response = self._request_otp()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["phone"], self.phone)
        self.assertEqual(response.data["cooldown_seconds"], 120)
        self.assertEqual(response.data["expires_in_seconds"], 600)
        self.assertNotIn("code", response.data)
        self.assertTrue(PhoneOtp.objects.filter(phone=self.phone).exists())

    def test_resend_within_cooldown_returns_429(self):
        first = self._request_otp()
        self.assertEqual(first.status_code, status.HTTP_200_OK)

        with patch("accounts.views.generate_otp_code", return_value="654321"):
            resend = self.client.post(
                "/api/accounts/otp/resend/",
                {"phone": self.phone},
                format="json",
            )
        self.assertEqual(resend.status_code, status.HTTP_429_TOO_MANY_REQUESTS)
        self.assertIn("detail", resend.data)
        self.assertIn("retry_after_seconds", resend.data)
        self.assertGreater(resend.data["retry_after_seconds"], 0)
        self.assertLessEqual(resend.data["retry_after_seconds"], COOLDOWN_SECONDS)

    def test_resend_after_cooldown_succeeds(self):
        self._request_otp()
        otp = PhoneOtp.objects.filter(phone=self.phone).latest("last_sent_at")
        otp.last_sent_at = timezone.now() - timedelta(seconds=COOLDOWN_SECONDS + 1)
        otp.save(update_fields=["last_sent_at"])

        with patch("accounts.views.generate_otp_code", return_value="654321"):
            resend = self.client.post(
                "/api/accounts/otp/resend/",
                {"phone": self.phone},
                format="json",
            )
        self.assertEqual(resend.status_code, status.HTTP_200_OK)
        self.assertEqual(resend.data["cooldown_seconds"], 120)

    def test_verify_creates_user_and_returns_token_profile(self):
        self._request_otp()
        response = self._verify()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("token", response.data)
        user = response.data["user"]
        self.assertEqual(user["phone"], self.phone)
        self.assertIsNone(user["name"])
        self.assertIsNone(user["image_url"])
        self.assertEqual(len(user["id"]), 32)
        self.assertIn("created_at", user)
        self.assertIn("updated_at", user)
        self.assertTrue(UserProfile.objects.filter(phone=self.phone).exists())
        self.assertTrue(Token.objects.filter(key=response.data["token"]).exists())

    def test_verify_existing_phone_signs_in(self):
        self._request_otp()
        first = self._verify()
        token1 = first.data["token"]
        public_id = first.data["user"]["id"]

        self._request_otp(code="999999")
        second = self._verify(code="999999")
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(second.data["token"], token1)
        self.assertEqual(second.data["user"]["id"], public_id)
        self.assertEqual(UserProfile.objects.filter(phone=self.phone).count(), 1)

    def test_verify_bad_code_rejected(self):
        self._request_otp()
        response = self._verify(code="000000")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("detail", response.data)
        self.assertFalse(Token.objects.exists())

    def test_verify_expired_code_rejected(self):
        self._request_otp()
        otp = PhoneOtp.objects.filter(phone=self.phone).latest("last_sent_at")
        otp.expires_at = timezone.now() - timedelta(seconds=1)
        otp.save(update_fields=["expires_at"])
        response = self._verify()
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_profile_get_and_patch_name(self):
        self._request_otp()
        verify = self._verify()
        self._auth(verify.data["token"])

        get_resp = self.client.get("/api/accounts/profile/")
        self.assertEqual(get_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(get_resp.data["phone"], self.phone)
        self.assertEqual(get_resp.data["id"], verify.data["user"]["id"])

        patch_resp = self.client.patch(
            "/api/accounts/profile/",
            {"name": "Ada"},
            format="json",
        )
        self.assertEqual(patch_resp.status_code, status.HTTP_200_OK)
        self.assertEqual(patch_resp.data["name"], "Ada")
        # id / phone not writable
        locked = self.client.patch(
            "/api/accounts/profile/",
            {"id": "deadbeef" * 4, "phone": "+10000000000", "name": "Bob"},
            format="json",
        )
        self.assertEqual(locked.status_code, status.HTTP_200_OK)
        self.assertEqual(locked.data["name"], "Bob")
        self.assertEqual(locked.data["id"], verify.data["user"]["id"])
        self.assertEqual(locked.data["phone"], self.phone)

    def test_profile_patch_image(self):
        self._request_otp()
        verify = self._verify()
        self._auth(verify.data["token"])

        from io import BytesIO

        from PIL import Image

        buf = BytesIO()
        Image.new("RGB", (8, 8), color=(200, 100, 50)).save(buf, format="PNG")
        upload = SimpleUploadedFile(
            "avatar.png",
            buf.getvalue(),
            content_type="image/png",
        )
        response = self.client.patch(
            "/api/accounts/profile/",
            {"image": upload},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)
        self.assertIsNotNone(response.data["image_url"])
        self.assertIn("/media/", response.data["image_url"])

    def test_logout_deletes_token(self):
        self._request_otp()
        verify = self._verify()
        token_key = verify.data["token"]
        self._auth(token_key)

        logout = self.client.post("/api/accounts/logout/")
        self.assertEqual(logout.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Token.objects.filter(key=token_key).exists())

        # Token no longer works
        profile = self.client.get("/api/accounts/profile/")
        self.assertEqual(profile.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_unauthenticated_profile_401(self):
        response = self.client.get("/api/accounts/profile/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_otp_never_in_response_body(self):
        # Use a code that cannot appear as a substring of phone / numeric fields.
        response = self._request_otp(code="777888")
        self.assertNotIn("code", response.data)
        self.assertNotIn("otp", response.data)
        body = response.content.decode()
        self.assertNotIn("777888", body)

    def test_debug_stores_plaintext_code_for_admin(self):
        self._request_otp(code="777888")
        otp = PhoneOtp.objects.filter(phone=self.phone).latest("last_sent_at")
        self.assertEqual(otp.debug_code, "777888")

    def test_admin_lists_debug_code_when_debug(self):
        from accounts.admin import PhoneOtpAdmin

        admin = PhoneOtpAdmin(PhoneOtp, admin_site=None)
        self.assertIn("debug_code", admin.get_list_display(request=None))
        self.assertEqual(admin.get_exclude(request=None), ())

    def test_invalid_phone_rejected(self):
        response = self.client.post(
            "/api/accounts/otp/request/",
            {"phone": "not-a-phone"},
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


@override_settings(DEBUG=True)
class DeviceRegistrationTests(APITestCase):
    phone_a = "+989121234567"
    phone_b = "+989129876543"
    code = "123456"
    device_id = "install-aaaa-bbbb-cccc"
    fcm_token = "fcm-token-alpha"

    def _signup(self, phone: str) -> str:
        with patch("accounts.views.generate_otp_code", return_value=self.code):
            request = self.client.post(
                "/api/accounts/otp/request/",
                {"phone": phone},
                format="json",
            )
        self.assertEqual(request.status_code, status.HTTP_200_OK)
        verify = self.client.post(
            "/api/accounts/otp/verify/",
            {"phone": phone, "code": self.code},
            format="json",
        )
        self.assertEqual(verify.status_code, status.HTTP_200_OK)
        return verify.data["token"]

    def _auth(self, token_key: str):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token_key}")

    def _put_registration(self, device_id=None, fcm_token=None):
        return self.client.put(
            "/api/accounts/registrations/",
            {
                "device_id": self.device_id if device_id is None else device_id,
                "fcm_token": self.fcm_token if fcm_token is None else fcm_token,
            },
            format="json",
        )

    def test_unauthenticated_put_401(self):
        response = self._put_registration()
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_registration(self):
        token = self._signup(self.phone_a)
        self._auth(token)

        response = self._put_registration()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["device_id"], self.device_id)
        self.assertEqual(response.data["fcm_token"], self.fcm_token)
        self.assertIn("created_at", response.data)
        self.assertIn("updated_at", response.data)

        profile = UserProfile.objects.get(phone=self.phone_a)
        row = DeviceRegistration.objects.get(user=profile.user, device_id=self.device_id)
        self.assertEqual(row.fcm_token, self.fcm_token)
        self.assertEqual(DeviceRegistration.objects.filter(user=profile.user).count(), 1)

    def test_same_device_id_updates_fcm_token(self):
        token = self._signup(self.phone_a)
        self._auth(token)

        first = self._put_registration(fcm_token="token-v1")
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        created_at = first.data["created_at"]

        second = self._put_registration(fcm_token="token-v2")
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(second.data["device_id"], self.device_id)
        self.assertEqual(second.data["fcm_token"], "token-v2")
        self.assertEqual(second.data["created_at"], created_at)

        profile = UserProfile.objects.get(phone=self.phone_a)
        self.assertEqual(
            DeviceRegistration.objects.filter(user=profile.user).count(),
            1,
        )
        row = DeviceRegistration.objects.get(user=profile.user, device_id=self.device_id)
        self.assertEqual(row.fcm_token, "token-v2")

    def test_different_device_id_creates_second_row(self):
        token = self._signup(self.phone_a)
        self._auth(token)

        first = self._put_registration(device_id="device-one", fcm_token="tok-1")
        second = self._put_registration(device_id="device-two", fcm_token="tok-2")
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertEqual(second.status_code, status.HTTP_200_OK)

        profile = UserProfile.objects.get(phone=self.phone_a)
        rows = DeviceRegistration.objects.filter(user=profile.user).order_by("device_id")
        self.assertEqual(rows.count(), 2)
        self.assertEqual(rows[0].device_id, "device-one")
        self.assertEqual(rows[0].fcm_token, "tok-1")
        self.assertEqual(rows[1].device_id, "device-two")
        self.assertEqual(rows[1].fcm_token, "tok-2")

    def test_user_isolation_same_device_id(self):
        token_a = self._signup(self.phone_a)
        token_b = self._signup(self.phone_b)

        self._auth(token_a)
        resp_a = self._put_registration(fcm_token="token-a")
        self.assertEqual(resp_a.status_code, status.HTTP_200_OK)

        self._auth(token_b)
        resp_b = self._put_registration(fcm_token="token-b")
        self.assertEqual(resp_b.status_code, status.HTTP_200_OK)
        self.assertEqual(resp_b.data["fcm_token"], "token-b")

        user_a = UserProfile.objects.get(phone=self.phone_a).user
        user_b = UserProfile.objects.get(phone=self.phone_b).user
        row_a = DeviceRegistration.objects.get(user=user_a, device_id=self.device_id)
        row_b = DeviceRegistration.objects.get(user=user_b, device_id=self.device_id)
        self.assertEqual(row_a.fcm_token, "token-a")
        self.assertEqual(row_b.fcm_token, "token-b")
        self.assertNotEqual(row_a.pk, row_b.pk)

        # User B overwrite must not touch User A's row.
        self._auth(token_b)
        overwrite = self._put_registration(fcm_token="token-b-updated")
        self.assertEqual(overwrite.status_code, status.HTTP_200_OK)
        row_a.refresh_from_db()
        row_b.refresh_from_db()
        self.assertEqual(row_a.fcm_token, "token-a")
        self.assertEqual(row_b.fcm_token, "token-b-updated")

    def test_empty_fields_rejected(self):
        token = self._signup(self.phone_a)
        self._auth(token)

        for payload in (
            {"device_id": "", "fcm_token": self.fcm_token},
            {"device_id": "   ", "fcm_token": self.fcm_token},
            {"device_id": self.device_id, "fcm_token": ""},
            {"device_id": self.device_id, "fcm_token": "   "},
            {"device_id": "", "fcm_token": ""},
        ):
            response = self.client.put(
                "/api/accounts/registrations/",
                payload,
                format="json",
            )
            self.assertEqual(
                response.status_code,
                status.HTTP_400_BAD_REQUEST,
                msg=payload,
            )

        self.assertFalse(DeviceRegistration.objects.exists())


@override_settings(DEBUG=False)
class AccountsSmsUnavailableTests(APITestCase):
    def test_request_otp_503_when_no_provider_and_not_debug(self):
        with patch.dict("os.environ", {"SMS_PROVIDER": "", "SMS_API_KEY": ""}, clear=False):
            response = self.client.post(
                "/api/accounts/otp/request/",
                {"phone": "+989121234567"},
                format="json",
            )
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertIn("detail", response.data)

    def test_admin_hides_debug_code_when_not_debug(self):
        from accounts.admin import PhoneOtpAdmin

        admin = PhoneOtpAdmin(PhoneOtp, admin_site=None)
        self.assertNotIn("debug_code", admin.get_list_display(request=None))
        self.assertEqual(admin.get_exclude(request=None), ("debug_code",))
