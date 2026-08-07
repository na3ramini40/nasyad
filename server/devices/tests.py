from datetime import datetime, timedelta, timezone

from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from devices.models import Device, DeviceLog


def _iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


class DeviceSyncTests(APITestCase):
    def setUp(self):
        self.user_a = User.objects.create_user(username="user_a", password="pass-a")
        self.user_b = User.objects.create_user(username="user_b", password="pass-b")
        self.token_a = Token.objects.create(user=self.user_a)
        self.token_b = Token.objects.create(user=self.user_b)
        self.t0 = datetime(2024, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.t1 = self.t0 + timedelta(hours=1)
        self.t2 = self.t0 + timedelta(hours=2)

    def _auth(self, token: Token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _device_payload(self, device_id="dev-1", **overrides):
        payload = {
            "id": device_id,
            "parent_id": None,
            "name": "Root Device",
            "description": None,
            "category_preset": "generic",
            "location_label": None,
            "status": "active",
            "usage_unit": "km",
            "current_usage": 0,
            "schedule_type": None,
            "interval_value": None,
            "interval_unit": None,
            "fixed_due_at": None,
            "last_maintained_at": None,
            "usage_at_last_maintenance": 0,
            "created_at": _iso(self.t0),
            "updated_at": _iso(self.t1),
        }
        payload.update(overrides)
        return payload

    def test_unauthenticated_devices_401(self):
        response = self.client.get("/api/devices/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_upsert_then_get(self):
        self._auth(self.token_a)
        create = self.client.put(
            "/api/devices/dev-1/",
            self._device_payload(),
            format="json",
        )
        self.assertEqual(create.status_code, status.HTTP_201_CREATED)
        self.assertEqual(create.data["id"], "dev-1")
        self.assertEqual(create.data["name"], "Root Device")
        self.assertNotIn("user", create.data)

        detail = self.client.get("/api/devices/dev-1/")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data["name"], "Root Device")

    def test_lww_older_updated_at_does_not_overwrite(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/dev-1/",
            self._device_payload(name="Newer", updated_at=_iso(self.t2)),
            format="json",
        )
        older = self.client.put(
            "/api/devices/dev-1/",
            self._device_payload(name="Older", updated_at=_iso(self.t1)),
            format="json",
        )
        self.assertEqual(older.status_code, status.HTTP_200_OK)
        self.assertEqual(older.data["name"], "Newer")
        self.assertEqual(Device.objects.get(id="dev-1").name, "Newer")

    def test_list_honors_updated_since(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/old/",
            self._device_payload(device_id="old", name="Old", updated_at=_iso(self.t0)),
            format="json",
        )
        self.client.put(
            "/api/devices/new/",
            self._device_payload(device_id="new", name="New", updated_at=_iso(self.t2)),
            format="json",
        )
        response = self.client.get(
            "/api/devices/",
            {"updated_since": _iso(self.t1)},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [row["id"] for row in response.data["results"]]
        self.assertEqual(ids, ["new"])

    def test_archive_cascades_to_subtree(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/root/",
            self._device_payload(device_id="root", name="Root"),
            format="json",
        )
        self.client.put(
            "/api/devices/child/",
            self._device_payload(device_id="child", parent_id="root", name="Child"),
            format="json",
        )
        self.client.put(
            "/api/devices/grandchild/",
            self._device_payload(
                device_id="grandchild",
                parent_id="child",
                name="Grandchild",
            ),
            format="json",
        )
        archive_at = _iso(self.t2)
        response = self.client.put(
            "/api/devices/root/",
            self._device_payload(
                device_id="root",
                name="Root",
                status="archived",
                updated_at=archive_at,
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Device.objects.get(id="root").status, "archived")
        self.assertEqual(Device.objects.get(id="child").status, "archived")
        self.assertEqual(Device.objects.get(id="grandchild").status, "archived")
        self.assertEqual(Device.objects.get(id="child").updated_at, self.t2)
        self.assertEqual(Device.objects.get(id="grandchild").updated_at, self.t2)

    def test_user_isolation_devices(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/a-only/",
            self._device_payload(device_id="a-only", name="A"),
            format="json",
        )
        self._auth(self.token_b)
        list_b = self.client.get("/api/devices/")
        self.assertEqual(list_b.data["results"], [])
        detail_b = self.client.get("/api/devices/a-only/")
        self.assertEqual(detail_b.status_code, status.HTTP_404_NOT_FOUND)

    def test_invalid_enum_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/devices/bad/",
            self._device_payload(device_id="bad", status="bogus"),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("status", response.data)

    def test_blank_name_rejected(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/devices/blank/",
            self._device_payload(device_id="blank", name="  "),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


class DeviceLogSyncTests(APITestCase):
    def setUp(self):
        self.user_a = User.objects.create_user(username="log_a", password="pass-a")
        self.user_b = User.objects.create_user(username="log_b", password="pass-b")
        self.token_a = Token.objects.create(user=self.user_a)
        self.token_b = Token.objects.create(user=self.user_b)
        self.t0 = datetime(2024, 2, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.t1 = self.t0 + timedelta(hours=1)
        self.t2 = self.t0 + timedelta(hours=2)

    def _auth(self, token: Token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _log_payload(self, log_id="log-1", **overrides):
        payload = {
            "id": log_id,
            "device_id": "dev-1",
            "date": _iso(self.t0),
            "notes": "oil change",
            "kind": "maintenanceDone",
            "usage_value": None,
            "usage_unit": None,
            "cost": "12.50",
            "cost_currency": "USD",
            "vendor": "Shop",
            "created_at": _iso(self.t1),
        }
        payload.update(overrides)
        return payload

    def test_unauthenticated_logs_401(self):
        response = self.client.get("/api/devices/logs/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_log_upsert_idempotent(self):
        self._auth(self.token_a)
        first = self.client.put(
            "/api/devices/logs/log-1/",
            self._log_payload(notes="first"),
            format="json",
        )
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(first.data["notes"], "first")

        second = self.client.put(
            "/api/devices/logs/log-1/",
            self._log_payload(notes="changed"),
            format="json",
        )
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(second.data["notes"], "first")
        self.assertEqual(DeviceLog.objects.get(id="log-1").notes, "first")

    def test_list_honors_created_since(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/logs/old/",
            self._log_payload(log_id="old", created_at=_iso(self.t0)),
            format="json",
        )
        self.client.put(
            "/api/devices/logs/new/",
            self._log_payload(log_id="new", created_at=_iso(self.t2)),
            format="json",
        )
        response = self.client.get(
            "/api/devices/logs/",
            {"created_since": _iso(self.t1)},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [row["id"] for row in response.data["results"]]
        self.assertEqual(ids, ["new"])

    def test_user_isolation_logs(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/logs/a-log/",
            self._log_payload(log_id="a-log"),
            format="json",
        )
        self._auth(self.token_b)
        self.assertEqual(self.client.get("/api/devices/logs/").data["results"], [])
        self.assertEqual(
            self.client.get("/api/devices/logs/a-log/").status_code,
            status.HTTP_404_NOT_FOUND,
        )

    def test_invalid_kind_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/devices/logs/bad/",
            self._log_payload(log_id="bad", kind="notAKind"),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("kind", response.data)

    def test_ignores_photo_fields(self):
        self._auth(self.token_a)
        payload = self._log_payload()
        payload["photo_path"] = "/local/x.jpg"
        payload["photo_base64"] = "abc"
        response = self.client.put("/api/devices/logs/log-photo/", payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertNotIn("photo_path", response.data)
        self.assertNotIn("photo_base64", response.data)
