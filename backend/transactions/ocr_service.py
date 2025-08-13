import os
import google.generativeai as genai
from google.generativeai import types
from pydantic import BaseModel

from dotenv import load_dotenv
load_dotenv()

class ReceiptData(BaseModel):
    fidelity_card_number: str = ''
    store_name: str = ''
    transaction_date: str = None
    total_amount: float = 0.0
    items: list[dict] = []
    raw_ocr_text: str = ''
    processed_by_user: str = ''
    flagged_for_review: bool = False
    flag_reasons: list = []
    reviewed: bool = False


api_key = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=api_key)

client = genai.Client()



def process_receipt_ocr(image_data )-> list[ReceiptData]:
    # image_data: Django UploadedFile object
    image_bytes = image_data.read()
    prompt = (
        "Extract the following fields from this receipt image: "
        "fidelity_card_number, store_name, transaction_date, total_amount, items (list of dictionaries where each item has 3 keys: name, amount, quantity). "
    )

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=[
            {"role": "user", "parts": [prompt, {"mime_type": "image/jpeg", "data": image_bytes}]}
        ],
        config={
            "response_mime_type": "application/json",
            "response_schema": [ReceiptData],
        },
    )
    # Parse and return the structured result
    return response.parsed