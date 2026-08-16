from django.urls import path

from devices.views import (
    DeviceDetailView,
    DeviceListView,
    DeviceLogDetailView,
    DeviceLogListView,
    DeviceTagLinkDetailView,
    DeviceTagLinkListView,
    TagDetailView,
    TagListView,
)

urlpatterns = [
    path("logs/", DeviceLogListView.as_view(), name="device-log-list"),
    path("logs/<str:id>/", DeviceLogDetailView.as_view(), name="device-log-detail"),
    path("tags/", TagListView.as_view(), name="tag-list"),
    path("tags/<str:id>/", TagDetailView.as_view(), name="tag-detail"),
    path("tag-links/", DeviceTagLinkListView.as_view(), name="device-tag-link-list"),
    path(
        "tag-links/<str:device_id>/<str:tag_id>/",
        DeviceTagLinkDetailView.as_view(),
        name="device-tag-link-detail",
    ),
    path("", DeviceListView.as_view(), name="device-list"),
    path("<str:id>/", DeviceDetailView.as_view(), name="device-detail"),
]
