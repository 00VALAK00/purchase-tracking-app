from django.shortcuts import render
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from django.contrib.auth.models import User
from users.models import UserProfile
from users.serializers import UserSerializer, UserProfileSerializer
from rest_framework.views import APIView

# Create your views here.

class AdminUserListCreateView(generics.ListCreateAPIView):
    queryset = UserProfile.objects.select_related('user').all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAdminUser]

class AdminUserDetailView(generics.RetrieveUpdateDestroyAPIView):
    queryset = UserProfile.objects.select_related('user').all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAdminUser]

class AdminSystemStatsView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def get(self, request):
        # Placeholder values; replace with real queries when transactions are implemented
        total_transactions = 0
        flagged_transactions = 0
        active_users = UserProfile.objects.filter(is_active=True).count()
        processing_accuracy = 1.0
        return Response({
            "total_transactions": total_transactions,
            "flagged_transactions": flagged_transactions,
            "active_users": active_users,
            "processing_accuracy": processing_accuracy
        })
