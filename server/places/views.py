from django.utils.dateparse import parse_datetime
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from places.models import Place
from places.serializers import PlaceSerializer


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


class PlaceListView(APIView):
    def get(self, request):
        qs = Place.objects.filter(user=request.user)
        since = _parse_since(request.query_params.get("updated_since"))
        if since is not None:
            qs = qs.filter(updated_at__gt=since)
        qs = qs.order_by("updated_at")
        return Response({"results": PlaceSerializer(qs, many=True).data})


class PlaceDetailView(APIView):
    def get(self, request, id: str):
        try:
            place = Place.objects.get(user=request.user, id=id)
        except Place.DoesNotExist:
            return Response({"detail": "Not found."}, status=status.HTTP_404_NOT_FOUND)
        return Response(PlaceSerializer(place).data)

    def put(self, request, id: str):
        data = dict(request.data)
        data["id"] = id
        existing = Place.objects.filter(user=request.user, id=id).first()

        if existing is not None:
            parsed = _parse_datetime(data.get("updated_at"))
            if parsed is not None and existing.updated_at > parsed:
                return Response(PlaceSerializer(existing).data, status=status.HTTP_200_OK)

            serializer = PlaceSerializer(existing, data=data, partial=False)
            serializer.is_valid(raise_exception=True)
            place = serializer.save(user=request.user)
            return Response(PlaceSerializer(place).data, status=status.HTTP_200_OK)

        serializer = PlaceSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        place = serializer.save(user=request.user)
        return Response(PlaceSerializer(place).data, status=status.HTTP_201_CREATED)
