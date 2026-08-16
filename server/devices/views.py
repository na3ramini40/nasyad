from django.db import transaction
from django.utils.dateparse import parse_datetime
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from devices.log_effects import apply_log_side_effects
from devices.models import Device, DeviceLog, DeviceTagLink, Tag
from devices.serializers import (
    DeviceLogSerializer,
    DeviceSerializer,
    DeviceTagLinkSerializer,
    TagSerializer,
)


def _parse_datetime(value) -> object | None:
    if value is None:
        return None
    text = str(value).strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    return parse_datetime(text)


def _parse_since(value: str | None):
    return _parse_datetime(value)


def _cascade_status(user, parent_id: str, new_status: str, updated_at) -> None:
    """Archive/delete the entire subtree under parent_id for this user."""
    children = list(
        Device.objects.filter(user=user, parent_id=parent_id).values_list("id", flat=True)
    )
    if not children:
        return
    Device.objects.filter(user=user, id__in=children).update(
        status=new_status,
        updated_at=updated_at,
    )
    for child_id in children:
        _cascade_status(user, child_id, new_status, updated_at)


class DeviceListView(APIView):
    def get(self, request):
        qs = Device.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("updated_since"))
        if since is not None:
            qs = qs.filter(updated_at__gt=since)
        qs = qs.order_by("updated_at")
        return Response({"results": DeviceSerializer(qs, many=True).data})


class DeviceDetailView(APIView):
    def get(self, request, id: str):
        try:
            device = Device.objects.get(user=request.user, id=id)
        except Device.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(DeviceSerializer(device).data)

    def put(self, request, id: str):
        data = dict(request.data)
        data["id"] = id
        existing = Device.objects.filter(user=request.user, id=id).first()

        if existing is not None:
            parsed = _parse_datetime(data.get("updated_at"))
            if parsed is not None and existing.updated_at > parsed:
                return Response(DeviceSerializer(existing).data, status=status.HTTP_200_OK)

            serializer = DeviceSerializer(existing, data=data, partial=False)
            serializer.is_valid(raise_exception=True)
            with transaction.atomic():
                device = serializer.save(user=request.user)
                if device.status in (Device.Status.ARCHIVED, Device.Status.DELETED):
                    _cascade_status(
                        request.user,
                        device.id,
                        device.status,
                        device.updated_at,
                    )
            return Response(DeviceSerializer(device).data, status=status.HTTP_200_OK)

        serializer = DeviceSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            device = serializer.save(user=request.user)
            if device.status in (Device.Status.ARCHIVED, Device.Status.DELETED):
                _cascade_status(
                    request.user,
                    device.id,
                    device.status,
                    device.updated_at,
                )
        return Response(DeviceSerializer(device).data, status=status.HTTP_201_CREATED)


class DeviceLogListView(APIView):
    def get(self, request):
        qs = DeviceLog.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("created_since"))
        if since is not None:
            qs = qs.filter(created_at__gt=since)
        qs = qs.order_by("created_at")
        return Response({"results": DeviceLogSerializer(qs, many=True).data})


class DeviceLogDetailView(APIView):
    def get(self, request, id: str):
        try:
            log = DeviceLog.objects.get(user=request.user, id=id)
        except DeviceLog.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(DeviceLogSerializer(log).data)

    def put(self, request, id: str):
        existing = DeviceLog.objects.filter(user=request.user, id=id).first()
        if existing is not None:
            return Response(DeviceLogSerializer(existing).data, status=status.HTTP_200_OK)

        data = dict(request.data)
        data["id"] = id
        # Ignore client-local / transit-only photo fields.
        data.pop("photo_path", None)
        data.pop("photo_base64", None)

        serializer = DeviceLogSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        with transaction.atomic():
            log = serializer.save(user=request.user)
            apply_log_side_effects(user=request.user, log=log)
        return Response(DeviceLogSerializer(log).data, status=status.HTTP_201_CREATED)


class TagListView(APIView):
    def get(self, request):
        qs = Tag.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("updated_since"))
        if since is not None:
            qs = qs.filter(updated_at__gt=since)
        qs = qs.order_by("updated_at")
        return Response({"results": TagSerializer(qs, many=True).data})


class TagDetailView(APIView):
    def get(self, request, id: str):
        try:
            tag = Tag.objects.get(user=request.user, id=id)
        except Tag.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(TagSerializer(tag).data)

    def put(self, request, id: str):
        data = dict(request.data)
        data["id"] = id
        existing = Tag.objects.filter(user=request.user, id=id).first()

        if existing is not None:
            parsed = _parse_datetime(data.get("updated_at"))
            if parsed is not None and existing.updated_at > parsed:
                return Response(TagSerializer(existing).data, status=status.HTTP_200_OK)

            serializer = TagSerializer(existing, data=data, partial=False)
            serializer.is_valid(raise_exception=True)
            tag = serializer.save(user=request.user)
            return Response(TagSerializer(tag).data, status=status.HTTP_200_OK)

        serializer = TagSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        tag = serializer.save(user=request.user)
        return Response(TagSerializer(tag).data, status=status.HTTP_201_CREATED)

    def delete(self, request, id: str):
        tag = Tag.objects.filter(user=request.user, id=id).first()
        if tag is None:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        with transaction.atomic():
            DeviceTagLink.objects.filter(user=request.user, tag_id=id).delete()
            tag.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class DeviceTagLinkListView(APIView):
    def get(self, request):
        qs = DeviceTagLink.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("created_since"))
        if since is not None:
            qs = qs.filter(created_at__gt=since)
        qs = qs.order_by("created_at")
        return Response({"results": DeviceTagLinkSerializer(qs, many=True).data})


class DeviceTagLinkDetailView(APIView):
    def put(self, request, device_id: str, tag_id: str):
        existing = DeviceTagLink.objects.filter(
            user=request.user,
            device_id=device_id,
            tag_id=tag_id,
        ).first()
        if existing is not None:
            return Response(
                DeviceTagLinkSerializer(existing).data,
                status=status.HTTP_200_OK,
            )

        data = dict(request.data)
        data["device_id"] = device_id
        data["tag_id"] = tag_id
        serializer = DeviceTagLinkSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        link = serializer.save(user=request.user)
        return Response(DeviceTagLinkSerializer(link).data, status=status.HTTP_201_CREATED)

    def delete(self, request, device_id: str, tag_id: str):
        deleted, _ = DeviceTagLink.objects.filter(
            user=request.user,
            device_id=device_id,
            tag_id=tag_id,
        ).delete()
        if not deleted:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(status=status.HTTP_204_NO_CONTENT)
