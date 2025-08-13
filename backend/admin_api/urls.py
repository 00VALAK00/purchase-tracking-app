from django.urls import path
from .views import AdminUserListCreateView, AdminUserDetailView, AdminSystemStatsView

urlpatterns = [
    path('users/', AdminUserListCreateView.as_view(), name='admin-user-list-create'),
    path('users/<int:pk>/', AdminUserDetailView.as_view(), name='admin-user-detail'),
    path('system-stats/', AdminSystemStatsView.as_view(), name='admin-system-stats'),
] 