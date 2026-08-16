from django.contrib import admin

from places.models import Place


@admin.register(Place)
class PlaceAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "kind", "updated_at")
    list_filter = ("kind",)
    search_fields = ("id", "name")
