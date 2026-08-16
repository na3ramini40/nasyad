from rest_framework import serializers

from places.models import Place

_MIN_POINTS = {
    Place.Kind.POINT: 1,
    Place.Kind.LINE: 2,
    Place.Kind.POLYGON: 3,
}


class PlaceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Place
        fields = [
            "id",
            "name",
            "kind",
            "points",
            "notes",
            "created_at",
            "updated_at",
        ]

    def validate_name(self, value: str) -> str:
        if value is None or not str(value).strip():
            raise serializers.ValidationError("This field may not be blank.")
        return value.strip()

    def validate_points(self, value):
        if not isinstance(value, list):
            raise serializers.ValidationError("Must be a list of {lat, lng} objects.")
        for i, item in enumerate(value):
            if not isinstance(item, dict):
                raise serializers.ValidationError(
                    f"points[{i}] must be an object with lat and lng."
                )
            if "lat" not in item or "lng" not in item:
                raise serializers.ValidationError(
                    f"points[{i}] must include lat and lng."
                )
            try:
                float(item["lat"])
                float(item["lng"])
            except (TypeError, ValueError) as exc:
                raise serializers.ValidationError(
                    f"points[{i}] lat and lng must be numbers."
                ) from exc
        return value

    def validate(self, attrs):
        kind = attrs.get("kind")
        if kind is None and self.instance is not None:
            kind = self.instance.kind
        points = attrs.get("points")
        if points is None and self.instance is not None:
            points = self.instance.points

        if kind is not None and points is not None:
            minimum = _MIN_POINTS.get(kind)
            if minimum is not None and len(points) < minimum:
                raise serializers.ValidationError(
                    {
                        "points": (
                            f"{kind} requires at least {minimum} "
                            f"point{'s' if minimum != 1 else ''}."
                        )
                    }
                )
        return attrs
