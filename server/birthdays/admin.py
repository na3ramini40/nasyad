from django.contrib import admin

from birthdays.models import Birthday


@admin.register(Birthday)
class BirthdayAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "birth_month", "birth_day", "calendar_system", "updated_at")
    list_filter = ("calendar_system",)
    search_fields = ("id", "name")
