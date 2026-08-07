from django.contrib.auth.models import User
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.test import APITestCase

from app_config.evaluation import cohort_bucket, evaluate_flag
from app_config.models import FeatureFlag


class AppConfigApiTests(APITestCase):
    url = "/api/app_config/"

    def setUp(self):
        # Seed migration creates example_remote_flag; ensure known baseline.
        FeatureFlag.objects.update_or_create(
            key="example_remote_flag",
            defaults={
                "description": "Plumbing proof flag",
                "is_enabled": False,
                "rollout_percent": 0,
            },
        )

    def _auth(self, user: User):
        token, _ = Token.objects.get_or_create(user=user)
        self.client.credentials(HTTP_AUTHORIZATION=f"Token {token.key}")

    def test_anonymous_get_returns_features_and_updated_at(self):
        FeatureFlag.objects.create(
            key="full_rollout",
            description="On for everyone",
            is_enabled=True,
            rollout_percent=100,
        )
        FeatureFlag.objects.create(
            key="partial_rollout",
            description="Auth sticky only",
            is_enabled=True,
            rollout_percent=50,
        )

        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("updated_at", response.data)
        self.assertIn("features", response.data)
        features = response.data["features"]
        self.assertFalse(features["example_remote_flag"])
        self.assertTrue(features["full_rollout"])
        self.assertFalse(features["partial_rollout"])

    def test_authenticated_sticky_cohort_is_stable(self):
        flag = FeatureFlag.objects.create(
            key="sticky_flag",
            description="Half rollout",
            is_enabled=True,
            rollout_percent=50,
        )
        user = User.objects.create_user(username="cohort_user", password="pass")
        expected = evaluate_flag(flag, user)
        self.assertEqual(
            expected,
            cohort_bucket(user.pk, flag.key) < flag.rollout_percent,
        )

        self._auth(user)
        first = self.client.get(self.url)
        second = self.client.get(self.url)
        self.assertEqual(first.status_code, status.HTTP_200_OK)
        self.assertEqual(second.status_code, status.HTTP_200_OK)
        self.assertEqual(first.data["features"]["sticky_flag"], expected)
        self.assertEqual(second.data["features"]["sticky_flag"], expected)

    def test_different_users_can_differ_on_partial_rollout(self):
        flag = FeatureFlag.objects.create(
            key="split_flag",
            description="Half rollout",
            is_enabled=True,
            rollout_percent=50,
        )
        # Find two users that land on opposite sides of the 50% cut.
        in_cohort = None
        out_cohort = None
        for i in range(200):
            user = User.objects.create_user(username=f"u{i}", password="pass")
            bucket = cohort_bucket(user.pk, flag.key)
            if bucket < 50 and in_cohort is None:
                in_cohort = user
            elif bucket >= 50 and out_cohort is None:
                out_cohort = user
            if in_cohort is not None and out_cohort is not None:
                break

        self.assertIsNotNone(in_cohort)
        self.assertIsNotNone(out_cohort)
        self.assertTrue(evaluate_flag(flag, in_cohort))
        self.assertFalse(evaluate_flag(flag, out_cohort))

        self._auth(in_cohort)
        in_response = self.client.get(self.url)
        self.assertTrue(in_response.data["features"]["split_flag"])

        self._auth(out_cohort)
        out_response = self.client.get(self.url)
        self.assertFalse(out_response.data["features"]["split_flag"])

    def test_kill_switch_overrides_full_rollout(self):
        FeatureFlag.objects.create(
            key="killed_flag",
            description="Enabled false at 100%",
            is_enabled=False,
            rollout_percent=100,
        )
        user = User.objects.create_user(username="kill_user", password="pass")

        anon = self.client.get(self.url)
        self.assertEqual(anon.status_code, status.HTTP_200_OK)
        self.assertFalse(anon.data["features"]["killed_flag"])

        self._auth(user)
        auth = self.client.get(self.url)
        self.assertEqual(auth.status_code, status.HTTP_200_OK)
        self.assertFalse(auth.data["features"]["killed_flag"])

    def test_cohort_bucket_range_and_stability(self):
        a = cohort_bucket(1, "example_remote_flag")
        b = cohort_bucket(1, "example_remote_flag")
        self.assertEqual(a, b)
        self.assertGreaterEqual(a, 0)
        self.assertLess(a, 100)
        self.assertNotEqual(
            cohort_bucket(1, "example_remote_flag"),
            cohort_bucket(2, "example_remote_flag"),
        )
