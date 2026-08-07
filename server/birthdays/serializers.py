from rest_framework import serializers

from birthdays.models import Birthday


class BirthdaySerializer(serializers.ModelSerializer):
    class Meta:
        model = Birthday
        fields = [
            "id",
            "name",
            "birth_month",
            "birth_day",
            "calendar_system",
            "created_at",
            "updated_at",
        ]

    def validate_name(self, value: str) -> str:
        if value is None or not str(value).strip():
            raise serializers.ValidationError("This field may not be blank.")
        return value.strip()

    def validate_birth_month(self, value: int) -> int:
        if value < 1 or value > 12:
            raise serializers.ValidationError("Must be between 1 and 12.")
        return value

    def validate_birth_day(self, value: int) -> int:
        if value < 1 or value > 31:
            raise serializers.ValidationError("Must be between 1 and 31.")
        return value
