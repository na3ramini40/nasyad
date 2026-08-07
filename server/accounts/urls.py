from django.urls import path

from accounts.views import (
    DeviceRegistrationView,
    LogoutView,
    OtpRequestView,
    OtpResendView,
    OtpVerifyView,
    ProfileView,
)

urlpatterns = [
    path("otp/request/", OtpRequestView.as_view(), name="accounts-otp-request"),
    path("otp/resend/", OtpResendView.as_view(), name="accounts-otp-resend"),
    path("otp/verify/", OtpVerifyView.as_view(), name="accounts-otp-verify"),
    path("profile/", ProfileView.as_view(), name="accounts-profile"),
    path(
        "registrations/",
        DeviceRegistrationView.as_view(),
        name="accounts-registrations",
    ),
    path("logout/", LogoutView.as_view(), name="accounts-logout"),
]
