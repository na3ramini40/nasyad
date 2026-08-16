from datetime import datetime, timedelta, timezone

from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from places.models import Place


def _iso(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


class PlaceSyncTests(APITestCase):
    def setUp(self):
        self.user_a = User.objects.create_user(username="place_a", password="pass-a")
        self.user_b = User.objects.create_user(username="place_b", password="pass-b")
        self.token_a = Token.objects.create(user=self.user_a)
        self.token_b = Token.objects.create(user=self.user_b)
        self.t0 = datetime(2024, 3, 1, 12, 0, 0, tzinfo=timezone.utc)
        self.t1 = self.t0 + timedelta(hours=1)
        self.t2 = self.t0 + timedelta(hours=2)

    def _auth(self, token: Token):
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def _payload(self, place_id="place-1", **overrides):
        payload = {
            "id": place_id,
            "name": "Home",
            "kind": "point",
            "points": [{"lat": 35.7, "lng": 51.4}],
            "notes": "front door",
            "created_at": _iso(self.t0),
            "updated_at": _iso(self.t1),
        }
        payload.update(overrides)
        return payload

    def test_unauthenticated_401(self):
        response = self.client.get("/api/places/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_upsert_then_get(self):
        self._auth(self.token_a)
        create = self.client.put(
            "/api/places/place-1/",
            self._payload(),
            format="json",
        )
        self.assertEqual(create.status_code, status.HTTP_201_CREATED)
        self.assertEqual(create.data["name"], "Home")
        self.assertEqual(create.data["kind"], "point")
        self.assertEqual(create.data["points"], [{"lat": 35.7, "lng": 51.4}])
        self.assertNotIn("user", create.data)

        detail = self.client.get("/api/places/place-1/")
        self.assertEqual(detail.status_code, status.HTTP_200_OK)
        self.assertEqual(detail.data["notes"], "front door")

    def test_lww_older_updated_at_does_not_overwrite(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/places/place-1/",
            self._payload(name="Newer", updated_at=_iso(self.t2)),
            format="json",
        )
        older = self.client.put(
            "/api/places/place-1/",
            self._payload(name="Older", updated_at=_iso(self.t1)),
            format="json",
        )
        self.assertEqual(older.status_code, status.HTTP_200_OK)
        self.assertEqual(older.data["name"], "Newer")
        self.assertEqual(Place.objects.get(id="place-1").name, "Newer")

    def test_list_honors_updated_since(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/places/old/",
            self._payload(place_id="old", name="Old", updated_at=_iso(self.t0)),
            format="json",
        )
        self.client.put(
            "/api/places/new/",
            self._payload(place_id="new", name="New", updated_at=_iso(self.t2)),
            format="json",
        )
        response = self.client.get(
            "/api/places/",
            {"updated_since": _iso(self.t1)},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        ids = [row["id"] for row in response.data["results"]]
        self.assertEqual(ids, ["new"])

    def test_user_isolation(self):
        self._auth(self.token_a)
        self.client.put(
            "/api/places/a-only/",
            self._payload(place_id="a-only"),
            format="json",
        )
        self._auth(self.token_b)
        self.assertEqual(self.client.get("/api/places/").data["results"], [])
        self.assertEqual(
            self.client.get("/api/places/a-only/").status_code,
            status.HTTP_404_NOT_FOUND,
        )

    def test_invalid_kind_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/places/bad/",
            self._payload(place_id="bad", kind="circle"),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("kind", response.data)

    def test_invalid_points_too_few_for_kind(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/places/bad-line/",
            self._payload(
                place_id="bad-line",
                kind="line",
                points=[{"lat": 1.0, "lng": 2.0}],
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("points", response.data)

        response = self.client.put(
            "/api/places/bad-poly/",
            self._payload(
                place_id="bad-poly",
                kind="polygon",
                points=[
                    {"lat": 1.0, "lng": 2.0},
                    {"lat": 3.0, "lng": 4.0},
                ],
            ),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("points", response.data)

    def test_blank_name_400(self):
        self._auth(self.token_a)
        response = self.client.put(
            "/api/places/blank/",
            self._payload(place_id="blank", name="   "),
            format="json",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("name", response.data)
