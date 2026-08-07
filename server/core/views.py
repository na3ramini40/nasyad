from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from core.serializers import RegisterSerializer, TokenLoginSerializer


class HealthView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def get(self, _request):
        return Response({"status": "ok", "service": "nasyad-server"})


class RegisterView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        payload = serializer.save()
        return Response(payload, status=status.HTTP_201_CREATED)


class TokenLoginView(APIView):
    authentication_classes = []
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = TokenLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data["auth_payload"], status=status.HTTP_200_OK)
