from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from rest_framework import serializers
from rest_framework.authtoken.models import Token


class RegisterSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, trim_whitespace=True)
    password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate_username(self, value: str) -> str:
        if not value:
            raise serializers.ValidationError("This field may not be blank.")
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("A user with that username already exists.")
        return value

    def validate_password(self, value: str) -> str:
        if not value:
            raise serializers.ValidationError("This field may not be blank.")
        return value

    def create(self, validated_data: dict) -> dict:
        user = User.objects.create_user(
            username=validated_data["username"],
            password=validated_data["password"],
        )
        token, _ = Token.objects.get_or_create(user=user)
        return {"token": token.key, "user_id": user.id, "username": user.username}


class TokenLoginSerializer(serializers.Serializer):
    username = serializers.CharField(max_length=150, trim_whitespace=True)
    password = serializers.CharField(write_only=True, trim_whitespace=False)

    def validate(self, attrs: dict) -> dict:
        username = attrs.get("username") or ""
        password = attrs.get("password") or ""
        if not username or not password:
            raise serializers.ValidationError("Username and password are required.")
        user = authenticate(username=username, password=password)
        if user is None:
            raise serializers.ValidationError("Unable to log in with provided credentials.")
        token, _ = Token.objects.get_or_create(user=user)
        attrs["auth_payload"] = {
            "token": token.key,
            "user_id": user.id,
            "username": user.username,
        }
        return attrs
