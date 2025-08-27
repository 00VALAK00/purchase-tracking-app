import requests


BASE = "http://localhost:8000"
URL = f"{BASE}/api/receipts/process/"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzU1ODQzMDE5LCJpYXQiOjE3NTU4NDI3MTksImp0aSI6IjNhY2M5MjUyZDZiODRjN2JhMTMyOTJjNmVjMDdkZDk0IiwidXNlcl9pZCI6IjcifQ.WlS1-158_O4hNVYc_APsZowQ9G81OMAmr7xjwOX4pO8"
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