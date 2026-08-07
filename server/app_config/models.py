from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class FeatureFlag(models.Model):
    key = models.SlugField(
        max_length=128,
        unique=True,
        help_text="Stable snake_case flag id (e.g. example_remote_flag).",
    )
    description = models.TextField(blank=True, default="")
    is_enabled = models.BooleanField(
        default=False,
        help_text="Kill switch: false evaluates to false for everyone.",
    )
    rollout_percent = models.PositiveSmallIntegerField(
        default=0,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text="0–100; sticky cohort when authenticated.",
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["key"]

    def __str__(self) -> str:
        return self.key
