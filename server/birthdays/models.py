from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Birthday(models.Model):
    class CalendarSystem(models.TextChoices):
        GREGORIAN = "gregorian", "gregorian"
        PERSIAN = "persian", "persian"

    id = models.CharField(primary_key=True, max_length=36)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="birthdays",
    )
    name = models.CharField(max_length=255)
    birth_month = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(12)],
    )
    birth_day = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(31)],
    )
    calendar_system = models.CharField(
        max_length=16,
        choices=CalendarSystem.choices,
    )
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        indexes = [
            models.Index(fields=["user", "updated_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.name} ({self.id})"
