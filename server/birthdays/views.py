from django.utils.dateparse import parse_datetime
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from birthdays.models import Birthday
from birthdays.serializers import BirthdaySerializer


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


class BirthdayListView(APIView):
    def get(self, request):
        qs = Birthday.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("updated_since"))
        if since is not None:
            qs = qs.filter(updated_at__gt=since)
        qs = qs.order_by("updated_at")
        return Response({"results": BirthdaySerializer(qs, many=True).data})


class BirthdayDetailView(APIView):
    def get(self, request, id: str):
        try:
            birthday = Birthday.objects.get(user=request.user, id=id)
        except Birthday.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(BirthdaySerializer(birthday).data)

    def put(self, request, id: str):
        data = dict(request.data)
        data["id"] = id
        existing = Birthday.objects.filter(user=request.user, id=id).first()

        if existing is not None:
            parsed = _parse_datetime(data.get("updated_at"))
            if parsed is not None and existing.updated_at > parsed:
                return Response(BirthdaySerializer(existing).data, status=status.HTTP_200_OK)

            serializer = BirthdaySerializer(existing, data=data, partial=False)
            serializer.is_valid(raise_exception=True)
            birthday = serializer.save(user=request.user)
            return Response(BirthdaySerializer(birthday).data, status=status.HTTP_200_OK)

        serializer = BirthdaySerializer(data=data)
        serializer.is_valid(raise_exception=True)
        birthday = serializer.save(user=request.user)
        return Response(BirthdaySerializer(birthday).data, status=status.HTTP_201_CREATED)
