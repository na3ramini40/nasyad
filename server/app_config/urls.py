from django.urls import path

from app_config.views import AppConfigView

urlpatterns = [
    path("", AppConfigView.as_view(), name="app-config"),
]
