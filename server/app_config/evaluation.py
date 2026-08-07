"""Evaluate FeatureFlag rows for anonymous or authenticated callers."""

from __future__ import annotations

import hashlib
from typing import Any

from django.utils import timezone

from app_config.models import FeatureFlag


def cohort_bucket(user_id: Any, key: str) -> int:
    """Stable 0–99 bucket from (user pk, flag key)."""
    digest = hashlib.sha256(f"{user_id}:{key}".encode()).hexdigest()
    return int(digest, 16) % 100


def evaluate_flag(flag: FeatureFlag, user) -> bool:
    """Return evaluated bool for one flag and optional authenticated user."""
    if not flag.is_enabled:
        return False

    if user is not None and getattr(user, "is_authenticated", False):
        return cohort_bucket(user.pk, flag.key) < flag.rollout_percent

    # Anonymous: only fully rolled-out flags are on.
    return flag.rollout_percent >= 100


def build_config_payload(user=None) -> dict:
    """Build GET /api/app_config/ response body for the given caller."""
    flags = list(FeatureFlag.objects.all())
    features = {flag.key: evaluate_flag(flag, user) for flag in flags}
    updated_at = max((flag.updated_at for flag in flags), default=timezone.now())

    return {
        "updated_at": updated_at,
        "features": features,
    }
