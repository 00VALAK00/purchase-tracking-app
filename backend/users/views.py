from django.shortcuts import render
from django.contrib.auth.models import User
from .models import UserProfile
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from .serializers import UserSerializer, UserProfileSerializer

class RegisterUserView(generics.CreateAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user_data = serializer.validated_data.pop('user')
            user = User.objects.create_user(**user_data)
            profile = UserProfile.objects.create(user=user, **serializer.validated_data)
            response_serializer = self.get_serializer(profile)
            return Response(response_serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserProfileView(generics.RetrieveAPIView):
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return UserProfile.objects.get(user=self.request.user)
