from rest_framework import serializers
from .models import Transaction, Item

class ItemSerializer(serializers.Serializer):
    name = serializers.CharField()
    quantity = serializers.IntegerField()
    amount = serializers.FloatField()

class TransactionSerializer(serializers.Serializer):
    transaction_id = serializers.CharField()
    user_id = serializers.IntegerField()  # Read-only, set from request.user
    created_at = serializers.DateTimeField(read_only=True)
    total_amount = serializers.FloatField()
    items = ItemSerializer(many=True)
    raw_ocr_text = serializers.CharField(required=False, allow_blank=True)
    fidelity_card_number = serializers.CharField(required=False, allow_blank=True)
    fidelity_card_applied = serializers.BooleanField(required=False, default=False)

    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        items = [Item(**item) for item in items_data]
        return Transaction.objects.create(items=items, **validated_data)

    def update(self, instance, validated_data):
        items_data = validated_data.pop('items', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        if items_data is not None:
            instance.items = [Item(**item) for item in items_data]
        instance.save()
        return instance 