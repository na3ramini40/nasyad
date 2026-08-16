from rest_framework import serializers

from devices.models import Device, DeviceLog, DeviceTagLink, Tag


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = [
            "id",
            "parent_id",
            "name",
            "description",
            "category_preset",
            "location_label",
            "status",
            "usage_unit",
            "current_usage",
            "schedule_type",
            "interval_value",
            "interval_unit",
            "fixed_due_at",
            "last_maintained_at",
            "usage_at_last_maintenance",
            "created_at",
            "updated_at",
        ]
        extra_kwargs = {
            "parent_id": {"allow_null": True, "required": False},
            "description": {"allow_null": True, "required": False},
            "category_preset": {"allow_null": True, "required": False},
            "location_label": {"allow_null": True, "required": False},
            "usage_unit": {"allow_null": True, "required": False},
            "current_usage": {"required": False},
            "schedule_type": {"allow_null": True, "required": False},
            "interval_value": {"allow_null": True, "required": False},
            "interval_unit": {"allow_null": True, "required": False},
            "fixed_due_at": {"allow_null": True, "required": False},
            "last_maintained_at": {"allow_null": True, "required": False},
            "usage_at_last_maintenance": {"required": False},
            "status": {"required": False},
        }

    def validate_name(self, value: str) -> str:
        if value is None or not str(value).strip():
            raise serializers.ValidationError("This field may not be blank.")
        return value.strip()


class DeviceLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceLog
        fields = [
            "id",
            "device_id",
            "date",
            "notes",
            "kind",
            "usage_value",
            "usage_unit",
            "cost",
            "cost_currency",
            "vendor",
            "created_at",
        ]
        extra_kwargs = {
            "notes": {"allow_null": True, "required": False},
            "usage_value": {"allow_null": True, "required": False},
            "usage_unit": {"allow_null": True, "required": False},
            "cost": {"allow_null": True, "required": False},
            "cost_currency": {"allow_null": True, "required": False},
            "vendor": {"allow_null": True, "required": False},
        }


class TagSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tag
        fields = [
            "id",
            "name",
            "created_at",
            "updated_at",
        ]

    def validate_name(self, value: str) -> str:
        if value is None or not str(value).strip():
            raise serializers.ValidationError("This field may not be blank.")
        return value.strip()


class DeviceTagLinkSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceTagLink
        fields = [
            "device_id",
            "tag_id",
            "created_at",
        ]
