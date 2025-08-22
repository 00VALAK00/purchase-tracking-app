from django.apps import AppConfig
import os
from dotenv import load_dotenv
import mongoengine


class TransactionsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'transactions'

    def ready(self):
        # Connect to MongoDB using environment variables
        load_dotenv()
        mongo_uri = os.getenv('MONGODB_URI')
        if not mongo_uri:
            username = os.getenv('MONGODB_USERNAME')
            password = os.getenv('MONGODB_PASSWORD')
            db_name = os.getenv('MONGODB_DB')
            if username and password and db_name:
                mongo_uri = f"mongodb+srv://{username}:{password}@{db_name}.qbcui8f.mongodb.net/{db_name}?retryWrites=true&w=majority&appName={db_name}"
        if mongo_uri:
            try:
                mongoengine.connect(host=mongo_uri)
            except Exception:
                # Avoid raising at import time; logs can be added as needed
                pass
