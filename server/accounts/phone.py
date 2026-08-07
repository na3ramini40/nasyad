"""Phone normalization for OTP accounts."""

from __future__ import annotations

import re

from rest_framework import serializers

# E.164-ish: + then 8–15 digits (ITU max is 15 national digits + country).
_E164_RE = re.compile(r"^\+[1-9]\d{7,14}$")


def normalize_phone(raw: str) -> str:
    """Normalize to digits with a leading +. Raises ValidationError if invalid."""
    if raw is None:
        raise serializers.ValidationError("This field may not be blank.")
    text = str(raw).strip()
    if not text:
        raise serializers.ValidationError("This field may not be blank.")

    # Allow spaces, dashes, parentheses for user input; strip them.
    text = re.sub(r"[\s\-().]", "", text)

    if text.startswith("00"):
        text = "+" + text[2:]
    elif not text.startswith("+"):
        if not text.isdigit():
            raise serializers.ValidationError("Enter a valid phone number.")
        # Local IR mobiles (09…) → +98…; other bare digits assumed to include country code.
        if text.startswith("0") and len(text) >= 10:
            text = "+98" + text[1:]
        elif text.startswith("98") and len(text) >= 12:
            text = "+" + text
        else:
            text = "+" + text

    # Keep only + and digits.
    if not text.startswith("+") or not text[1:].isdigit():
        raise serializers.ValidationError("Enter a valid phone number.")

    if not _E164_RE.match(text):
        raise serializers.ValidationError("Enter a valid phone number in E.164 format.")

    return text
