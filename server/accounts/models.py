import secrets

from django.conf import settings
from django.db import models


def _default_public_id() -> str:
    return secrets.token_hex(16)


def profile_image_upload_to(instance, filename: str) -> str:
    ext = filename.rsplit(".", 1)[-1].lower() if "." in filename else "jpg"
    if len(ext) > 8:
        ext = "jpg"
    return f"profiles/{instance.public_id}.{ext}"


class UserProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="profile",
    )
    public_id = models.CharField(
        max_length=32,
        unique=True,
        default=_default_public_id,
        editable=False,
    )
    phone = models.CharField(max_length=32, unique=True)
    name = models.CharField(max_length=255, blank=True, default="")
    image = models.ImageField(
        upload_to=profile_image_upload_to,
        null=True,
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        indexes = [
            models.Index(fields=["phone"]),
            models.Index(fields=["public_id"]),
        ]

    def __str__(self) -> str:
        return f"{self.phone} ({self.public_id})"


class PhoneOtp(models.Model):
    phone = models.CharField(max_length=32, db_index=True)
    code_hash = models.CharField(max_length=128)
    # Populated only when settings.DEBUG at issue time; always blank in production.
    debug_code = models.CharField(max_length=8, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)
    last_sent_at = models.DateTimeField()
    expires_at = models.DateTimeField()
    attempt_count = models.PositiveSmallIntegerField(default=0)

    class Meta:
        indexes = [
            models.Index(fields=["phone", "-last_sent_at"]),
        ]

    def __str__(self) -> str:
        return f"OTP {self.phone} @ {self.last_sent_at}"


class DeviceRegistration(models.Model):
    """Per-install FCM registration keyed by (user, device_id)."""

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="device_registrations",
    )
    device_id = models.CharField(max_length=64)
    fcm_token = models.CharField(max_length=512)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=["user", "device_id"],
                name="accounts_deviceregistration_user_device_id_uniq",
            ),
        ]
        indexes = [
            models.Index(fields=["user", "device_id"]),
        ]

    def __str__(self) -> str:
        return f"{self.device_id} (user={self.user_id})"
