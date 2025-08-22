from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    role = models.CharField(max_length=20, choices=[
        ('client', 'Client'),
        ('admin', 'Admin')
    ])
    fidelity_card_number = models.CharField(max_length=50, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} ({self.role})"
    
    def get_transactions(self):
        """Get all transactions for this user from MongoDB"""
        try:
            from transactions.models import Transaction
            return Transaction.objects.filter(user_id=self.user.id).order_by('-created_at')
        except Exception:
            # Return empty queryset if MongoDB is not available
            from mongoengine.queryset.queryset import QuerySet
            return QuerySet(Transaction)
