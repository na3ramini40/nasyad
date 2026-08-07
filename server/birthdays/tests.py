from datetime import datetime, timedelta, timezone

from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from birthdays.models import Birthday


def _iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


class BirthdaySyncTests(APITestCase):
    def setUp(self):
        self.user_a = User.objects.create_user(username="bday_a", password="pass-a")
        self.user_b = User.objects.create_user(username="bday_b", password="pass-b")
        self.token_a = Token.objects.create(user=self.user_a)
        self.token_b = Token.objects.create(user=self.user_b)
        self.t0 = datetime(2024, 3, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.t1 = self.t0 + timedelta(hours=1)
        self.t2 = self.t0 + timedelta(hours=2)

    def _auth(self, token: Token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _payload(self, birthday_id="bday-1", **overrides):
        payload = {
            "id": birthday_id,
            "name": "Ada",
            "birth_month": 12,
            "birth_day": 10,
            "calendar_system": "gregorian",
            "created_at": _iso(self.t0),
            "updated_at": _iso(self.t1),
        }
        payload.update(overrides)
        return payload

    def test_unauthenticated_401(self):
        response = self.client.get("/api/birthdays/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_upsert_then_get(self):
        self._auth(self.token_a)
        create = self.client.put(
            "/api/birthdays/bday-1/",
            self._payload(),
            format="json",
        )
        self.assertEqual(create.status_code, status.HTTP_201_CREATED)
        self.assertEqual(create.data["name"], "Ada")
        self.assertNotIn("user", create.data)

        detail = self.client.get("/api/birthdays/bday-1/")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data["birth_month"], 12)

    def test_lww_older_updated_at_does_not_overwrite(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/birthdays/bday-1/",
            self._payload(name="Newer", updated_at=_iso(self.t2)),
            format="json",
        )
        older = self.client.put(
            "/api/birthdays/bday-1/",
            self._payload(name="Older", updated_at=_iso(self.t1)),
            format="json",
        )
        self.assertEqual(older.status_code, status.HTTP_200_OK)
        self.assertEqual(older.data["name"], "Newer")
        self.assertEqual(Birthday.objects.get(id="bday-1").name, "Newer")

    def test_list_honors_updated_since(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/birthdays/old/",
            self._payload(birthday_id="old", name="Old", updated_at=_iso(self.t0)),
            format="json",
        )
        self.client.put(
            "/api/birthdays/new/",
            self._payload(birthday_id="new", name="New", updated_at=_iso(self.t2)),
            format="json",
        )
        response = self.client.get(
            "/api/birthdays/",
            {"updated_since": _iso(self.t1)},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [row["id"] for row in response.data["results"]]
        self.assertEqual(ids, ["new"])

    def test_user_isolation(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/birthdays/a-only/",
            self._payload(birthday_id="a-only"),
            format="json",
        )
        self._auth(self.token_b)
        self.assertEqual(self.client.get("/api/birthdays/").data["results"], [])
        self.assertEqual(
            self.client.get("/api/birthdays/a-only/").status_code,
            status.HTTP_404_NOT_FOUND,
        )

    def test_invalid_calendar_system_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/birthdays/bad/",
            self._payload(birthday_id="bad", calendar_system="lunar"),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("calendar_system", response.data)

    def test_birth_month_out_of_range(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/birthdays/bad-month/",
            self._payload(birthday_id="bad-month", birth_month=13),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
