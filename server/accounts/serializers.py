from rest_framework import serializers

from accounts.models import DeviceRegistration, UserProfile
from accounts.phone import normalize_phone


class PhoneSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=32)

    def validate_phone(self, value: str) -> str:
        return normalize_phone(value)


class OtpVerifySerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=32)
    code = serializers.CharField(max_length=16)

    def validate_phone(self, value: str) -> str:
        return normalize_phone(value)

    def validate_code(self, value: str) -> str:
        code = (value or "").strip()
        if not code:
            raise serializers.ValidationError("This field may not be blank.")
        if not code.isdigit() or len(code) != 6:
            raise serializers.ValidationError("Enter the 6-digit code.")
        return code


class UserProfileSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source="public_id", read_only=True)
    image_url = serializers.SerializerMethodField()
    name = serializers.CharField(
        max_length=255,
        allow_blank=True,
        required=False,
        allow_null=True,
    )

    class Meta:
        model = UserProfile
        fields = (
            "id",
            "phone",
            "name",
            "image_url",
            "created_at",
            "updated_at",
            "image",
        )
        read_only_fields = ("id", "phone", "image_url", "created_at", "updated_at")
        extra_kwargs = {
            "image": {"write_only": True, "required": False},
        }

    def get_image_url(self, obj: UserProfile) -> str | None:
        if not obj.image:
            return None
        request = self.context.get("request")
        url = obj.image.url
        if request is not None:
            return request.build_absolute_uri(url)
        return url

    def validate_name(self, value):
        if value is None:
            return ""
        return value

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data.pop("image", None)
        # Empty name → null on the wire per domain (string | null).
        if data.get("name") == "":
            data["name"] = None
        return data


class DeviceRegistrationSerializer(serializers.ModelSerializer):
    device_id = serializers.CharField(max_length=64)
    fcm_token = serializers.CharField(max_length=512)

    class Meta:
        model = DeviceRegistration
        fields = ("device_id", "fcm_token", "created_at", "updated_at")
        read_only_fields = ("created_at", "updated_at")

    def _require_non_empty(self, value: str) -> str:
        cleaned = (value or "").strip()
        if not cleaned:
            raise serializers.ValidationError("This field may not be blank.")
        return cleaned

    def validate_device_id(self, value: str) -> str:
        return self._require_non_empty(value)

    def validate_fcm_token(self, value: str) -> str:
        return self._require_non_empty(value)
