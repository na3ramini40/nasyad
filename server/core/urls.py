from django.urls import path

from core.views import HealthView, RegisterView, TokenLoginView

urlpatterns = [
    path("health/", HealthView.as_view(), name="health"),
    path("auth/register/", RegisterView.as_view(), name="auth-register"),
    path("auth/token/", TokenLoginView.as_view(), name="auth-token"),
]
