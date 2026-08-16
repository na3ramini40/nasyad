from django.contrib import admin

from devices.models import Device, DeviceLog, DeviceTagLink, Tag


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


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "updated_at")
    search_fields = ("id", "name")


@admin.register(DeviceTagLink)
class DeviceTagLinkAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "device_id", "tag_id", "created_at")
    search_fields = ("device_id", "tag_id")
