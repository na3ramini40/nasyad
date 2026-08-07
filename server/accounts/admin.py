from django.conf import settings
from django.contrib import admin

from accounts.models import DeviceRegistration, PhoneOtp, UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("public_id", "phone", "name", "created_at", "updated_at")
    search_fields = ("public_id", "phone", "name")
    readonly_fields = ("public_id", "created_at", "updated_at")


@admin.register(PhoneOtp)
class PhoneOtpAdmin(admin.ModelAdmin):
    search_fields = ("phone",)

    def get_list_display(self, request):
        base = ("phone", "last_sent_at", "expires_at", "attempt_count")
        if settings.DEBUG:
            return ("phone", "debug_code", "last_sent_at", "expires_at", "attempt_count")
        return base

    def get_readonly_fields(self, request, obj=None):
        fields = ["code_hash", "created_at"]
        if settings.DEBUG:
            fields.append("debug_code")
        return fields

    def get_exclude(self, request, obj=None):
        if settings.DEBUG:
            return ()
        return ("debug_code",)


@admin.register(DeviceRegistration)
class DeviceRegistrationAdmin(admin.ModelAdmin):
    list_display = ("user_phone", "device_id", "fcm_token_short", "updated_at")
    search_fields = ("device_id", "fcm_token", "user__profile__phone")
    readonly_fields = ("created_at", "updated_at")
    list_select_related = ("user", "user__profile")

    @admin.display(description="phone", ordering="user__profile__phone")
    def user_phone(self, obj: DeviceRegistration) -> str:
        try:
            return obj.user.profile.phone
        except UserProfile.DoesNotExist:
            return str(obj.user_id)

    @admin.display(description="fcm_token")
    def fcm_token_short(self, obj: DeviceRegistration) -> str:
        token = obj.fcm_token or ""
        if len(token) <= 24:
            return token
        return f"{token[:12]}…{token[-8:]}"
