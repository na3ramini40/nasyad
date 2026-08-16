"""Device-log create side effects — mirrors client DeviceLogRepositoryImpl."""

from __future__ import annotations

from django.utils import timezone
from rest_framework.exceptions import ValidationError

from devices.models import Device, DeviceLog


def resolve_usage_owner(
    device: Device,
    by_id: dict[str, Device],
) -> Device | None:
    current: Device | None = device
    while current is not None:
        if current.usage_unit:
            return current
        parent_id = current.parent_id
        if not parent_id:
            return None
        current = by_id.get(parent_id)
    return None


def _require_absolute_usage(usage_value, current_usage: int) -> int:
    if usage_value is None or usage_value < 0:
        raise ValidationError({"usage_value": ["Usage value is required."]})
    if usage_value < current_usage:
        raise ValidationError(
            {"usage_value": ["Usage value cannot be less than current usage."]}
        )
    return int(usage_value)


def _max_updated_at(device: Device, *candidates) -> None:
    now = timezone.now()
    times = [device.updated_at, now]
    for value in candidates:
        if value is not None:
            times.append(value)
    device.updated_at = max(times)


def apply_log_side_effects(*, user, log: DeviceLog) -> None:
    try:
        device = Device.objects.get(user=user, id=log.device_id)
    except Device.DoesNotExist as exc:
        raise ValidationError({"device_id": ["Device not found."]}) from exc

    by_id = {d.id: d for d in Device.objects.filter(user=user)}
    device = by_id[log.device_id]

    if log.kind == DeviceLog.Kind.USAGE_UPDATE:
        _apply_usage_update(device=device, log=log, by_id=by_id)
    elif log.kind == DeviceLog.Kind.MAINTENANCE_DONE:
        _apply_maintenance_done(device=device, log=log, by_id=by_id)


def _apply_usage_update(
    *,
    device: Device,
    log: DeviceLog,
    by_id: dict[str, Device],
) -> None:
    owner = resolve_usage_owner(device, by_id)
    if owner is None:
        raise ValidationError({"device_id": ["No usage owner found for device."]})

    value = _require_absolute_usage(log.usage_value, owner.current_usage)
    owner.current_usage = value
    _max_updated_at(owner, log.created_at)
    owner.save(update_fields=["current_usage", "updated_at"])


def _apply_maintenance_done(
    *,
    device: Device,
    log: DeviceLog,
    by_id: dict[str, Device],
) -> None:
    now = timezone.now()
    owner = resolve_usage_owner(device, by_id)

    if owner is None:
        device.last_maintained_at = now
        device.usage_at_last_maintenance = device.current_usage
        device.updated_at = now
        device.save(
            update_fields=[
                "last_maintained_at",
                "usage_at_last_maintenance",
                "updated_at",
            ]
        )
        return

    value = _require_absolute_usage(log.usage_value, owner.current_usage)

    if owner.id == device.id:
        device.current_usage = value
        device.last_maintained_at = now
        device.usage_at_last_maintenance = value
        device.updated_at = now
        device.save(
            update_fields=[
                "current_usage",
                "last_maintained_at",
                "usage_at_last_maintenance",
                "updated_at",
            ]
        )
        return

    owner.current_usage = value
    owner.updated_at = now
    owner.save(update_fields=["current_usage", "updated_at"])

    device.last_maintained_at = now
    device.usage_at_last_maintenance = value
    device.updated_at = now
    device.save(
        update_fields=[
            "last_maintained_at",
            "usage_at_last_maintenance",
            "updated_at",
        ]
    )
