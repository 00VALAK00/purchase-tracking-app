from rest_framework import serializers
from .models import Transaction, Item

class ItemSerializer(serializers.Serializer):
    name = serializers.CharField()
    quantity = serializers.IntegerField()
    amount = serializers.FloatField()

class TransactionSerializer(serializers.Serializer):
    id = serializers.CharField(read_only=True)
    fidelity_card_number = serializers.CharField()
    store_name = serializers.CharField()
    transaction_date = serializers.DateTimeField()
    total_amount = serializers.FloatField()
    items = ItemSerializer(many=True)
    raw_ocr_text = serializers.CharField()
    processed_by_user = serializers.CharField()
    flagged_for_review = serializers.BooleanField()
    flag_reasons = serializers.ListField(child=serializers.CharField())
    reviewed = serializers.BooleanField()
    created_at = serializers.DateTimeField()

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