from django.shortcuts import render
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.contrib.auth.models import User
from users.models import UserProfile
from users.serializers import UserSerializer, UserProfileSerializer
from rest_framework.views import APIView

# Custom permission class for admin role
class IsAdminRole(permissions.BasePermission):
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        try:
            profile = UserProfile.objects.get(user=request.user)
            return profile.role == 'admin'
        except UserProfile.DoesNotExist:
            return False

# Create your views here.

class AdminUserListCreateView(generics.ListCreateAPIView):
    queryset = UserProfile.objects.select_related('user').all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminRole]

class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = UserProfile.objects.select_related('user').all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAdminRole]
