from django.conf import settings
from django.db import models


class Place(models.Model):
    class Kind(models.TextChoices):
        POINT = "point", "point"
        LINE = "line", "line"
        POLYGON = "polygon", "polygon"

    id = models.CharField(primary_key=True, max_length=36)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="places",
    )
    name = models.CharField(max_length=255)
    kind = models.CharField(max_length=16, choices=Kind.choices)
    points = models.JSONField()
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        indexes = [
            models.Index(fields=["user", "updated_at"]),
        ]

    def __str__(self) -> str:
        return f"{self.name} ({self.id})"
