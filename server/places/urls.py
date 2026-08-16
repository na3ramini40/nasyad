from django.urls import path

from places.views import PlaceDetailView, PlaceListView

urlpatterns = [
    path("", PlaceListView.as_view(), name="place-list"),
    path("<str:id>/", PlaceDetailView.as_view(), name="place-detail"),
]
