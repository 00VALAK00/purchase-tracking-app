from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=[
        ('client', 'Client'),
        ('fournisseur', 'Fournisseur'),
        ('admin', 'Admin')
    ])
    fidelity_card_number = models.CharField(max_length=50, blank=True)
    store_name = models.CharField(max_length=100, blank=True)  # For fournisseurs
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} ({self.role})"
