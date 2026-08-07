from django.contrib import admin

from app_config.models import FeatureFlag


@admin.register(FeatureFlag)
class FeatureFlagAdmin(admin.ModelAdmin):
    list_display = ("key", "is_enabled", "rollout_percent", "updated_at")
    list_filter = ("is_enabled",)
    search_fields = ("key", "description")
    readonly_fields = ("created_at", "updated_at")
