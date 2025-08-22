from django.db import models
import mongoengine as me
from datetime import datetime, timezone
import uuid


# Create your models here.

class Item(me.EmbeddedDocument):
    name = me.StringField(required=True)
    quantity = me.IntField(required=False)
    amount = me.FloatField(required=True)
    
class Transaction(me.Document):
    transaction_id = me.StringField(required=True)
    user_id = me.IntField(required=True)  # Link to Django User ID
    created_at = me.DateTimeField(required=False, default=lambda: datetime.now(timezone.utc))
    total_amount = me.FloatField(required=True)
    items = me.EmbeddedDocumentListField(Item)
    raw_ocr_text = me.StringField()
    fidelity_card_number = me.StringField(required=False)
    fidelity_card_applied = me.BooleanField(required=True)

    meta = {'collection': 'transactions'}
