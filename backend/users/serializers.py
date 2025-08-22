from django.contrib.auth.models import User
from rest_framework import serializers
from .models import UserProfile

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

class UserProfileCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating user profiles (no transaction fields)"""
    user = UserSerializer()

    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'role', 'fidelity_card_number', 'created_at']

class UserProfileSerializer(serializers.ModelSerializer):
    """Full serializer for viewing user profiles with transaction data"""
    user = UserSerializer()
    transaction_count = serializers.SerializerMethodField()
    recent_transactions = serializers.SerializerMethodField()
    all_transactions = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = ['id', 'user', 'role', 'fidelity_card_number', 'created_at', 'transaction_count', 'recent_transactions', 'all_transactions']
    
    def get_transaction_count(self, obj):
        """Get total number of transactions for this user"""
        try:
            return obj.get_transactions().count()
        except Exception:
            return 0

    def get_all_transactions(self, obj):
        """Get all transactions for this user"""
        try:
            transactions = obj.get_transactions()
            return [{
                'transaction_id': t.transaction_id,
                'total_amount': t.total_amount,
                'created_at': t.created_at,
                'fidelity_card_applied': t.fidelity_card_applied,
                'fidelity_card_number': t.fidelity_card_number,
            } for t in transactions]
        except Exception:
            return []

    def get_recent_transactions(self, obj):
        """Get recent transactions (last 5) for this user"""
        try:
            transactions = obj.get_transactions()[:5]
            return [{
                'transaction_id': t.transaction_id,
                'total_amount': t.total_amount,
                'created_at': t.created_at,
                'fidelity_card_applied': t.fidelity_card_applied,
                'fidelity_card_number': t.fidelity_card_number,
            } for t in transactions]
        except Exception:
            return [] 