import os
import json
import io
from typing import Any, Dict, List
import uuid

from django.core.files.uploadedfile import UploadedFile
from PIL import Image
from dotenv import load_dotenv
import google.genai as genai
from pydantic import BaseModel, Field

load_dotenv()

class ItemData(BaseModel):
    name: str
    quantity: int
    amount: float

class ReceiptData(BaseModel):
    transaction_id: str = Field(description="The unique identifier for the transaction, if available. Can be an order number or receipt number.")
    total_amount: float = Field(default=0.0, description="The total amount of the transaction.")
    items: List[ItemData] = Field(default_factory=list, description="A list of items in the receipt and their corresponding prices.")


api_key = os.getenv('GOOGLE_API_KEY')
client = genai.Client(api_key=api_key)


def postprocess_step(extracted_data: str, **kwargs) -> Dict:
    # Accept JSON string or dict, normalize to dict
    
    data = json.loads(extracted_data)

    # Add/update fields from kwargs (with simple validation)
    for k,v in kwargs.items():
        data[k]= v

    # case the transaction does not have an unique identifier
    if "N/A" in data["transaction_id"]:
        data["transaction_id"] = uuid.uuid4().hex

    # Return as JSON string (pretty optional)
    return data



def process_receipt_ocr(image_data: UploadedFile)-> str:
    # image_data: Django UploadedFile object
    data = image_data.read()
    image = Image.open(io.BytesIO(data),mode="r")

    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=["extract the relevant information from this receipt. If a field is not found fill it with N/A", image],
        config={
                "response_mime_type": "application/json",
                "response_schema": ReceiptData,
            },
        )
    # Parse and return the structured result
    #  
    return response.text