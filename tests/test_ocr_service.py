import requests


BASE = "http://localhost:8000"
URL = f"{BASE}/api/receipts/process/"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU1NjI5MjYzLCJpYXQiOjE3NTU2Mjg5NjMsImp0aSI6ImMxMTM1ZjYyMmQzNDRiYTY4ZjM5MzVhNGExMDdjMDVlIiwidXNlcl9pZCI6IjEifQ.a8JTQdRSBjLTC4D9v_JgB6pyTvtxRp-QpLduLBlBGZo"

headers = {"Authorization": f"Bearer {TOKEN}"}
files = {"image": ("receipt-template.jpg", open("tests/data/receipt-template.png", "rb"), "image/png")}
data = {"fidelity_card_number": "FC-123456"}

resp = requests.post(URL, headers=headers, files=files, data=data, timeout=30)
print(resp.status_code, resp.text)

assert resp.status_code == 201, resp.text
body = resp.json()
# assert "transaction_id" in body
# assert "total_amount" in body
# assert isinstance(body.get("items", []), list)