from django.conf import settings
from django.contrib.auth.models import User
from django.db import transaction
from django.utils import timezone
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.models import DeviceRegistration, PhoneOtp, UserProfile
from accounts.serializers import (
    DeviceRegistrationSerializer,
    OtpVerifySerializer,
    PhoneSerializer,
    UserProfileSerializer,
)
from accounts.services import (
    COOLDOWN_SECONDS,
    EXPIRES_IN_SECONDS,
    MAX_VERIFY_ATTEMPTS,
    SmsNotConfigured,
    cooldown_remaining,
    deliver_otp,
    generate_otp_code,
    hash_otp_code,
    otp_expiry_from_now,
    verify_otp_code,
)


def _otp_success_payload(phone: str) -> dict:
    return {
        "phone": phone,
        "cooldown_seconds": COOLDOWN_SECONDS,
        "expires_in_seconds": EXPIRES_IN_SECONDS,
    }


def _issue_and_send_otp(phone: str) -> None:
    code = generate_otp_code()
    now = timezone.now()
    deliver_otp(phone, code)
    PhoneOtp.objects.create(
        phone=phone,
        code_hash=hash_otp_code(phone, code),
        debug_code=code if settings.DEBUG else "",
        last_sent_at=now,
        expires_at=otp_expiry_from_now(),
        attempt_count=0,
    )


def _latest_otp(phone: str) -> PhoneOtp | None:
    return PhoneOtp.objects.filter(phone=phone).order_by("-last_sent_at").first()


def _profile_response(profile: UserProfile, request) -> dict:
    return UserProfileSerializer(profile, context={"request": request}).data


class OtpRequestView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PhoneSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]
        try:
            _issue_and_send_otp(phone)
        except SmsNotConfigured as exc:
            return Response(
                {"detail": str(exc)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        return Response(_otp_success_payload(phone), status=status.HTTP_200_OK)


class OtpResendView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PhoneSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]

        latest = _latest_otp(phone)
        if latest is not None:
            remaining = cooldown_remaining(latest.last_sent_at)
            if remaining > 0:
                return Response(
                    {
                        "detail": "Please wait before requesting another code.",
                        "retry_after_seconds": remaining,
                    },
                    status=status.HTTP_429_TOO_MANY_REQUESTS,
                )

        try:
            _issue_and_send_otp(phone)
        except SmsNotConfigured as exc:
            return Response(
                {"detail": str(exc)},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )
        return Response(_otp_success_payload(phone), status=status.HTTP_200_OK)


class OtpVerifyView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = OtpVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        phone = serializer.validated_data["phone"]
        code = serializer.validated_data["code"]

        otp = _latest_otp(phone)
        if otp is None:
            return Response(
                {"detail": "Invalid or expired code."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.expires_at <= timezone.now():
            return Response(
                {"detail": "Invalid or expired code."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if otp.attempt_count >= MAX_VERIFY_ATTEMPTS:
            return Response(
                {"detail": "Too many attempts. Request a new code."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if not verify_otp_code(phone, code, otp.code_hash):
            PhoneOtp.objects.filter(pk=otp.pk).update(
                attempt_count=otp.attempt_count + 1,
            )
            return Response(
                {"detail": "Invalid or expired code."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        with transaction.atomic():
            profile = UserProfile.objects.select_related("user").filter(phone=phone).first()
            if profile is None:
                # Username is phone-derived; password unusable (OTP-only).
                username = f"phone:{phone}"
                if len(username) > 150:
                    username = username[:150]
                user = User.objects.create_user(username=username)
                user.set_unusable_password()
                user.save(update_fields=["password"])
                profile = UserProfile.objects.create(user=user, phone=phone)
            else:
                user = profile.user

            token, _ = Token.objects.get_or_create(user=user)
            PhoneOtp.objects.filter(phone=phone).delete()

        return Response(
            {
                "token": token.key,
                "user": _profile_response(profile, request),
            },
            status=status.HTTP_200_OK,
        )


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def _get_profile(self, request) -> UserProfile | None:
        try:
            return request.user.profile
        except UserProfile.DoesNotExist:
            return None

    def get(self, request):
        profile = self._get_profile(request)
        if profile is None:
            return Response(
                {"detail": "Profile not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(_profile_response(profile, request))

    def patch(self, request):
        profile = self._get_profile(request)
        if profile is None:
            return Response(
                {"detail": "Profile not found."},
                status=status.HTTP_404_NOT_FOUND,
            )
        serializer = UserProfileSerializer(
            profile,
            data=request.data,
            partial=True,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        # Never allow id/phone/public_id via API — serializer read_only covers this.
        serializer.save()
        profile.refresh_from_db()
        return Response(_profile_response(profile, request))


class DeviceRegistrationView(APIView):
    """Upsert per-install FCM registration for the authenticated user."""

    permission_classes = [IsAuthenticated]

    def put(self, request):
        serializer = DeviceRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        device_id = serializer.validated_data["device_id"]
        fcm_token = serializer.validated_data["fcm_token"]

        registration, _created = DeviceRegistration.objects.update_or_create(
            user=request.user,
            device_id=device_id,
            defaults={"fcm_token": fcm_token},
        )
        return Response(
            DeviceRegistrationSerializer(registration).data,
            status=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        token = getattr(request, "auth", None)
        if isinstance(token, Token):
            token.delete()
        else:
            Token.objects.filter(user=request.user).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
