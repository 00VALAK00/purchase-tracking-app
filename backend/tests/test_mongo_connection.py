
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv
import os

load_dotenv()

password = os.getenv('MONGODB_PASSWORD')
db_name = os.getenv('MONGODB_DB')
username = os.getenv('MONGODB_USERNAME')

print(password, db_name, username)
uri = f"mongodb+srv://{username}:{password}@{db_name}.qbcui8f.mongodb.net/?retryWrites=true&w=majority&appName={db_name}"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi('1'))

# Send a ping to confirm a successful connection
try:
    client.admin.command('ping')
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(e)