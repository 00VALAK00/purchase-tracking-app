from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi
from dotenv import load_dotenv
from pathlib import Path
import os


# Load env from backend/.env explicitly
env_path = Path(__file__).resolve().parents[1] / "backend" /".env"
print(env_path)
load_dotenv(env_path)

password = os.getenv("MONGODB_PASSWORD")
db_name = os.getenv("MONGODB_DB")
username = os.getenv("MONGODB_USERNAME")

if not all([username, password, db_name]):
    print("Missing MongoDB credentials in backend/.env (MONGODB_USERNAME, MONGODB_PASSWORD, MONGODB_DB)")
    raise SystemExit(1)

uri = f"mongodb+srv://{username}:{password}@{db_name}.qbcui8f.mongodb.net/?retryWrites=true&w=majority&appName={db_name}"

# Create a new client and connect to the server
client = MongoClient(uri, server_api=ServerApi("1"))

# Send a ping to confirm a successful connection
try:
    client.admin.command("ping")
    print("Pinged your deployment. You successfully connected to MongoDB!")
except Exception as e:
    print(f"MongoDB ping failed: {e}")
    raise