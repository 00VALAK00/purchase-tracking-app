from django.db import models
import mongoengine as me
from datetime import datetime

# Create your models here.

class Item(me.EmbeddedDocument):
    name = me.StringField(required=True)
    quantity = me.IntField(required=True)
    amount = me.FloatField(required=True)

class Transaction(me.Document):
    fidelity_card_number = me.StringField(required=True)
    store_name = me.StringField(required=True)
    transaction_date = me.DateTimeField(required=True)
    total_amount = me.FloatField(required=True)
    items = me.EmbeddedDocumentListField(Item)
    raw_ocr_text = me.StringField()
    processed_by_user = me.StringField()  # Store user id or username
    flagged_for_review = me.BooleanField(default=False)
    flag_reasons = me.ListField(me.StringField())
    reviewed = me.BooleanField(default=False)
    created_at = me.DateTimeField(default=datetime.utcnow)

    meta = {'collection': 'transactions'}
