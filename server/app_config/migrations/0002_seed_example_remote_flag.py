from django.db import migrations


def seed_example_flag(apps, schema_editor):
    FeatureFlag = apps.get_model("app_config", "FeatureFlag")
    FeatureFlag.objects.update_or_create(
        key="example_remote_flag",
        defaults={
            "description": "Plumbing proof flag — not for product gating.",
            "is_enabled": False,
            "rollout_percent": 0,
        },
    )


def unseed_example_flag(apps, schema_editor):
    FeatureFlag = apps.get_model("app_config", "FeatureFlag")
    FeatureFlag.objects.filter(key="example_remote_flag").delete()


class Migration(migrations.Migration):
    dependencies = [
        ("app_config", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(seed_example_flag, unseed_example_flag),
    ]
