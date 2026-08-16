from datetime import datetime, timedelta, timezone

from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from devices.models import Device, DeviceLog, DeviceTagLink, Tag


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

    def _put_device(self, device_id="dev-1", **overrides):
        return self.client.put(
            f"/api/devices/{device_id}/",
            self._device_payload(device_id=device_id, **overrides),
            format="json",
        )

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
        self._put_device(usage_unit=None)
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
        self._put_device(usage_unit=None)
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
        self._put_device(usage_unit=None)
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
        self._put_device(usage_unit=None)
        payload = self._log_payload()
        payload["photo_path"] = "/local/x.jpg"
        payload["photo_base64"] = "abc"
        response = self.client.put("/api/devices/logs/log-photo/", payload, format="json")
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertNotIn("photo_path", response.data)
        self.assertNotIn("photo_base64", response.data)

    def test_usage_update_advances_owner_without_resetting_baseline(self):
        self._auth(self.token_a)
        self._put_device(
            current_usage=1000,
            usage_at_last_maintenance=800,
            last_maintained_at=_iso(self.t0),
        )
        response = self.client.put(
            "/api/devices/logs/u1/",
            self._log_payload(
                log_id="u1",
                kind="usageUpdate",
                usage_value=1500,
                usage_unit="km",
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        device = Device.objects.get(id="dev-1")
        self.assertEqual(device.current_usage, 1500)
        self.assertEqual(device.usage_at_last_maintenance, 800)
        self.assertEqual(device.last_maintained_at, self.t0)

    def test_usage_update_rejects_decrease(self):
        self._auth(self.token_a)
        self._put_device(current_usage=2000)
        response = self.client.put(
            "/api/devices/logs/u-dec/",
            self._log_payload(
                log_id="u-dec",
                kind="usageUpdate",
                usage_value=1500,
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("usage_value", response.data)
        self.assertEqual(Device.objects.get(id="dev-1").current_usage, 2000)
        self.assertFalse(DeviceLog.objects.filter(id="u-dec").exists())

    def test_usage_update_rejects_missing_usage_value(self):
        self._auth(self.token_a)
        self._put_device()
        response = self.client.put(
            "/api/devices/logs/u-miss/",
            self._log_payload(
                log_id="u-miss",
                kind="usageUpdate",
                usage_value=None,
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("usage_value", response.data)
        self.assertFalse(DeviceLog.objects.filter(id="u-miss").exists())

    def test_maintenance_done_with_owner_updates_usage_and_baseline(self):
        self._auth(self.token_a)
        self._put_device(
            current_usage=1000,
            usage_at_last_maintenance=500,
            last_maintained_at=_iso(self.t0),
        )
        before = Device.objects.get(id="dev-1").last_maintained_at
        response = self.client.put(
            "/api/devices/logs/m1/",
            self._log_payload(
                log_id="m1",
                kind="maintenanceDone",
                usage_value=1200,
                usage_unit="km",
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        device = Device.objects.get(id="dev-1")
        self.assertEqual(device.current_usage, 1200)
        self.assertEqual(device.usage_at_last_maintenance, 1200)
        self.assertIsNotNone(device.last_maintained_at)
        self.assertGreater(device.last_maintained_at, before)

    def test_maintenance_done_on_child_updates_parent_km_child_baseline_only(self):
        self._auth(self.token_a)
        self._put_device(
            device_id="car",
            name="Car",
            current_usage=10000,
            usage_at_last_maintenance=9000,
            last_maintained_at=_iso(self.t0),
        )
        self._put_device(
            device_id="oil",
            name="Oil",
            parent_id="car",
            usage_unit=None,
            current_usage=0,
            usage_at_last_maintenance=0,
            last_maintained_at=None,
        )
        response = self.client.put(
            "/api/devices/logs/m-child/",
            self._log_payload(
                log_id="m-child",
                device_id="oil",
                kind="maintenanceDone",
                usage_value=10500,
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)

        parent = Device.objects.get(id="car")
        child = Device.objects.get(id="oil")
        self.assertEqual(parent.current_usage, 10500)
        self.assertEqual(parent.usage_at_last_maintenance, 9000)
        self.assertEqual(parent.last_maintained_at, self.t0)
        self.assertEqual(child.usage_at_last_maintenance, 10500)
        self.assertIsNotNone(child.last_maintained_at)
        self.assertEqual(child.current_usage, 0)

    def test_maintenance_done_without_usage_owner_no_usage_value_required(self):
        self._auth(self.token_a)
        self._put_device(
            usage_unit=None,
            current_usage=0,
            schedule_type="calendarInterval",
            interval_value=90,
            interval_unit="days",
        )
        response = self.client.put(
            "/api/devices/logs/m-cal/",
            self._log_payload(
                log_id="m-cal",
                kind="maintenanceDone",
                usage_value=None,
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        device = Device.objects.get(id="dev-1")
        self.assertIsNotNone(device.last_maintained_at)
        self.assertEqual(device.usage_at_last_maintenance, 0)

    def test_reput_same_log_does_not_double_apply_usage(self):
        self._auth(self.token_a)
        self._put_device(current_usage=1000)
        first = self.client.put(
            "/api/devices/logs/u-once/",
            self._log_payload(
                log_id="u-once",
                kind="usageUpdate",
                usage_value=2000,
            ),
            format="json",
        )
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Device.objects.get(id="dev-1").current_usage, 2000)

        Device.objects.filter(id="dev-1").update(current_usage=2500)

        second = self.client.put(
            "/api/devices/logs/u-once/",
            self._log_payload(
                log_id="u-once",
                kind="usageUpdate",
                usage_value=2000,
            ),
            format="json",
        )
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(Device.objects.get(id="dev-1").current_usage, 2500)

    def test_usage_update_bumps_device_into_updated_since_list(self):
        self._auth(self.token_a)
        self._put_device(current_usage=100, updated_at=_iso(self.t0))
        cursor = datetime.now(timezone.utc)
        response = self.client.put(
            "/api/devices/logs/u-bump/",
            self._log_payload(
                log_id="u-bump",
                kind="usageUpdate",
                usage_value=200,
                created_at=_iso(self.t1),
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        listed = self.client.get(
            "/api/devices/",
            {"updated_since": _iso(cursor)},
        )
        self.assertEqual(listed.status_code, status.HTTP_200_OK)
        ids = [row["id"] for row in listed.data["results"]]
        self.assertIn("dev-1", ids)
        self.assertEqual(
            next(r["current_usage"] for r in listed.data["results"] if r["id"] == "dev-1"),
            200,
        )

    def test_log_create_missing_device_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/devices/logs/no-dev/",
            self._log_payload(log_id="no-dev", kind="usageUpdate", usage_value=10),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("device_id", response.data)


class TagSyncTests(APITestCase):
    def setUp(self):
        self.user_a = User.objects.create_user(username="tag_a", password="pass-a")
        self.user_b = User.objects.create_user(username="tag_b", password="pass-b")
        self.token_a = Token.objects.create(user=self.user_a)
        self.token_b = Token.objects.create(user=self.user_b)
        self.t0 = datetime(2024, 3, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.t1 = self.t0 + timedelta(hours=1)
        self.t2 = self.t0 + timedelta(hours=2)

    def _auth(self, token: Token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _tag_payload(self, tag_id="tag-1", **overrides):
        payload = {
            "id": tag_id,
            "name": "Home",
            "created_at": _iso(self.t0),
            "updated_at": _iso(self.t1),
        }
        payload.update(overrides)
        return payload

    def test_tag_upsert_list_lww_and_user_isolation(self):
        self._auth(self.token_a)
        created = self.client.put(
            "/api/devices/tags/tag-1/",
            self._tag_payload(),
            format="json",
        )
        self.assertEqual(created.status_code, status.HTTP_201_CREATED)
        self.assertEqual(created.data["name"], "Home")
        self.assertNotIn("user", created.data)

        listed = self.client.get("/api/devices/tags/")
        self.assertEqual(len(listed.data["results"]), 1)

        self.client.put(
            "/api/devices/tags/tag-1/",
            self._tag_payload(name="Newer", updated_at=_iso(self.t2)),
            format="json",
        )
        older = self.client.put(
            "/api/devices/tags/tag-1/",
            self._tag_payload(name="Older", updated_at=_iso(self.t1)),
            format="json",
        )
        self.assertEqual(older.status_code, status.HTTP_200_OK)
        self.assertEqual(older.data["name"], "Newer")
        self.assertEqual(Tag.objects.get(id="tag-1").name, "Newer")

        filtered = self.client.get(
            "/api/devices/tags/",
            {"updated_since": _iso(self.t1)},
        )
        self.assertEqual([r["id"] for r in filtered.data["results"]], ["tag-1"])

        self._auth(self.token_b)
        self.assertEqual(self.client.get("/api/devices/tags/").data["results"], [])
        self.assertEqual(
            self.client.get("/api/devices/tags/tag-1/").status_code,
            status.HTTP_404_NOT_FOUND,
        )

    def test_tag_delete_removes_links(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/devices/tags/tag-1/",
            self._tag_payload(),
            format="json",
        )
        self.client.put(
            "/api/devices/tag-links/dev-1/tag-1/",
            {"created_at": _iso(self.t1)},
            format="json",
        )
        self.assertEqual(DeviceTagLink.objects.filter(tag_id="tag-1").count(), 1)

        deleted = self.client.delete("/api/devices/tags/tag-1/")
        self.assertEqual(deleted.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Tag.objects.filter(id="tag-1").exists())
        self.assertEqual(DeviceTagLink.objects.filter(tag_id="tag-1").count(), 0)

    def test_tag_link_put_list_delete_isolation_and_created_since(self):
        self._auth(self.token_a)
        first = self.client.put(
            "/api/devices/tag-links/dev-1/tag-1/",
            {"created_at": _iso(self.t0)},
            format="json",
        )
        self.assertEqual(first.status_code, status.HTTP_201_CREATED)
        self.assertEqual(first.data["device_id"], "dev-1")
        self.assertEqual(first.data["tag_id"], "tag-1")
        self.assertNotIn("user", first.data)

        again = self.client.put(
            "/api/devices/tag-links/dev-1/tag-1/",
            {"created_at": _iso(self.t2)},
            format="json",
        )
        self.assertEqual(again.status_code, status.HTTP_200_OK)
        self.assertEqual(again.data["created_at"], first.data["created_at"])
        self.assertEqual(DeviceTagLink.objects.filter(user=self.user_a).count(), 1)

        self.client.put(
            "/api/devices/tag-links/dev-2/tag-2/",
            {"created_at": _iso(self.t2)},
            format="json",
        )
        listed = self.client.get(
            "/api/devices/tag-links/",
            {"created_since": _iso(self.t1)},
        )
        self.assertEqual(listed.status_code, status.HTTP_200_OK)
        pairs = [(r["device_id"], r["tag_id"]) for r in listed.data["results"]]
        self.assertEqual(pairs, [("dev-2", "tag-2")])

        self._auth(self.token_b)
        self.assertEqual(self.client.get("/api/devices/tag-links/").data["results"], [])
        self.assertEqual(
            self.client.delete("/api/devices/tag-links/dev-1/tag-1/").status_code,
            status.HTTP_404_NOT_FOUND,
        )

        self._auth(self.token_a)
        removed = self.client.delete("/api/devices/tag-links/dev-1/tag-1/")
        self.assertEqual(removed.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(
            DeviceTagLink.objects.filter(
                user=self.user_a, device_id="dev-1", tag_id="tag-1"
            ).exists()
        )
