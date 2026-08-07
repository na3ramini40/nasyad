from django.conf import settings
from django.db import models


class Device(models.Model):
    class Status(models.TextChoices):
        ACTIVE = "active", "active"
        ARCHIVED = "archived", "archived"
        DELETED = "deleted", "deleted"

    class CategoryPreset(models.TextChoices):
        GENERIC = "generic", "generic"
        CAR = "car", "car"
        HVAC = "hvac", "hvac"
        APPLIANCE = "appliance", "appliance"
        ELECTRONICS = "electronics", "electronics"
        PLUMBING = "plumbing", "plumbing"

    class UsageUnit(models.TextChoices):
        KM = "km", "km"
        HOURS = "hours", "hours"
        CYCLES = "cycles", "cycles"

    class ScheduleType(models.TextChoices):
        CALENDAR_INTERVAL = "calendarInterval", "calendarInterval"
        USAGE_INTERVAL = "usageInterval", "usageInterval"
        FIXED_DATE = "fixedDate", "fixedDate"

    INTERVAL_UNITS = (
        ("days", "days"),
        ("weeks", "weeks"),
        ("months", "months"),
        ("km", "km"),
        ("hours", "hours"),
        ("cycles", "cycles"),
    )

    id = models.CharField(primary_key=True, max_length=36)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="devices",
    )
    parent_id = models.CharField(max_length=36, null=True, blank=True)
    name = models.CharField(max_length=255)
    description = models.TextField(null=True, blank=True)
    category_preset = models.CharField(
        max_length=32,
        choices=CategoryPreset.choices,
        null=True,
        blank=True,
    )
    location_label = models.CharField(max_length=255, null=True, blank=True)
    status = models.CharField(
        max_length=16,
        choices=Status.choices,
        default=Status.ACTIVE,
    )
    usage_unit = models.CharField(
        max_length=16,
        choices=UsageUnit.choices,
        null=True,
        blank=True,
    )
    current_usage = models.PositiveIntegerField(default=0)
    schedule_type = models.CharField(
        max_length=32,
        choices=ScheduleType.choices,
        null=True,
        blank=True,
    )
    interval_value = models.PositiveIntegerField(null=True, blank=True)
    interval_unit = models.CharField(
        max_length=16,
        choices=INTERVAL_UNITS,
        null=True,
        blank=True,
    )
    fixed_due_at = models.DateTimeField(null=True, blank=True)
    last_maintained_at = models.DateTimeField(null=True, blank=True)
    usage_at_last_maintenance = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        indexes = [
            models.Index(fields=["user", "updated_at"]),
            models.Index(fields=["user", "parent_id"]),
        ]

    def __str__(self) -> str:
        return f"{self.name} ({self.id})"


class DeviceLog(models.Model):
    class Kind(models.TextChoices):
        MAINTENANCE_DONE = "maintenanceDone", "maintenanceDone"
        USAGE_UPDATE = "usageUpdate", "usageUpdate"

    class UsageUnit(models.TextChoices):
        KM = "km", "km"
        HOURS = "hours", "hours"
        CYCLES = "cycles", "cycles"

    id = models.CharField(primary_key=True, max_length=36)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="device_logs",
    )
    device_id = models.CharField(max_length=36)
    date = models.DateTimeField()
    notes = models.TextField(null=True, blank=True)
    kind = models.CharField(max_length=32, choices=Kind.choices)
    usage_value = models.IntegerField(null=True, blank=True)
    usage_unit = models.CharField(
        max_length=16,
        choices=UsageUnit.choices,
        null=True,
        blank=True,
    )
    cost = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    cost_currency = models.CharField(max_length=16, null=True, blank=True)
    vendor = models.CharField(max_length=255, null=True, blank=True)
    created_at = models.DateTimeField()

    class Meta:
        indexes = [
            models.Index(fields=["user", "created_at"]),
            models.Index(fields=["user", "device_id"]),
        ]

    def __str__(self) -> str:
        return f"{self.kind} ({self.id})"
