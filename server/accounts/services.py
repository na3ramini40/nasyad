"""OTP generation, hashing, and delivery."""

from __future__ import annotations

import hashlib
import hmac
import logging
import os
import secrets
from datetime import timedelta

from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)

COOLDOWN_SECONDS = 120
EXPIRES_IN_SECONDS = 600
OTP_DIGITS = 6
MAX_VERIFY_ATTEMPTS = 5


class SmsNotConfigured(Exception):
    """Raised when SMS cannot be delivered (no provider and not DEBUG)."""


def generate_otp_code() -> str:
    upper = 10**OTP_DIGITS
    return f"{secrets.randbelow(upper):0{OTP_DIGITS}d}"


def hash_otp_code(phone: str, code: str) -> str:
    msg = f"{phone}:{code}".encode()
    key = settings.SECRET_KEY.encode()
    return hmac.new(key, msg, hashlib.sha256).hexdigest()


def verify_otp_code(phone: str, code: str, code_hash: str) -> bool:
    expected = hash_otp_code(phone, code)
    return hmac.compare_digest(expected, code_hash)


def sms_is_configured() -> bool:
    provider = (os.environ.get("SMS_PROVIDER") or "").strip()
    api_key = (os.environ.get("SMS_API_KEY") or "").strip()
    return bool(provider and api_key)


def deliver_otp(phone: str, code: str) -> None:
    """
    Deliver an OTP.

    If SMS credentials are unset and DEBUG is true: log the OTP to the console.
    If DEBUG is false and no provider: raise SmsNotConfigured (caller → 503).
    When credentials are set, delivery is still a stub (log intent); real SMS
    wiring lands when a provider is chosen.
    """
    if not sms_is_configured():
        if settings.DEBUG:
            logger.info(
                "[accounts.otp] DEBUG stub — phone=%s code=%s (SMS not configured)",
                phone,
                code,
            )
            return
        raise SmsNotConfigured(
            "SMS provider is not configured. Set SMS_PROVIDER and SMS_API_KEY."
        )

    provider = (os.environ.get("SMS_PROVIDER") or "").strip()
    # Provider credentials present — real gateway not wired yet.
    if settings.DEBUG:
        logger.info(
            "[accounts.otp] DEBUG stub via %s — phone=%s code=%s",
            provider,
            phone,
            code,
        )
        return
    logger.error(
        "[accounts.otp] SMS_PROVIDER=%s is set but delivery is not implemented.",
        provider,
    )
    raise SmsNotConfigured(
        "SMS delivery is not available. Contact the operator."
    )


def cooldown_remaining(last_sent_at) -> int:
    """Seconds until resend is allowed; 0 if allowed now."""
    if last_sent_at is None:
        return 0
    elapsed = (timezone.now() - last_sent_at).total_seconds()
    remaining = COOLDOWN_SECONDS - elapsed
    if remaining <= 0:
        return 0
    return int(remaining)


def otp_expiry_from_now():
    return timezone.now() + timedelta(seconds=EXPIRES_IN_SECONDS)
