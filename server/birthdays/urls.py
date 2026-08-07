from django.urls import path

from birthdays.views import BirthdayDetailView, BirthdayListView

urlpatterns = [
    path("", BirthdayListView.as_view(), name="birthday-list"),
    path("<str:id>/", BirthdayDetailView.as_view(), name="birthday-detail"),
]
