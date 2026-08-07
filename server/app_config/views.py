from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from app_config.evaluation import build_config_payload


class AppConfigView(APIView):
    """Remote feature-flag map. AllowAny; Token auth personalizes cohorts."""

    permission_classes = [AllowAny]

    def get(self, request):
        user = request.user if request.user.is_authenticated else None
        return Response(build_config_payload(user=user))
