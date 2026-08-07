from django.contrib import admin

from devices.models import Device, DeviceLog


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "status", "parent_id", "updated_at")
    list_filter = ("status",)
    search_fields = ("id", "name")


@admin.register(DeviceLog)
class DeviceLogAdmin(admin.ModelAdmin):
    list_display = ("id", "device_id", "user", "kind", "date", "created_at")
    list_filter = ("kind",)
    search_fields = ("id", "device_id")
