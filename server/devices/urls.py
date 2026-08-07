from django.urls import path

from devices.views import (
    DeviceDetailView,
    DeviceListView,
    DeviceLogDetailView,
    DeviceLogListView,
)

urlpatterns = [
    path("logs/", DeviceLogListView.as_view(), name="device-log-list"),
    path("logs/<str:id>/", DeviceLogDetailView.as_view(), name="device-log-detail"),
    path("", DeviceListView.as_view(), name="device-list"),
    path("<str:id>/", DeviceDetailView.as_view(), name="device-detail"),
]
