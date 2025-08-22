from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from .models import Transaction
from .serializers import TransactionSerializer
from users.models import UserProfile
from django.shortcuts import get_object_or_404

# POST /api/receipts/process/
class ReceiptProcessView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        # Expecting image file upload
        image_file = request.FILES.get('image')
        fidelity_card_number = request.POST.get("fidelity_card_number")
        fidelity_card_applied = False

        # Extract the fidelity card number 
        if not image_file:
            return Response({'error': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        if fidelity_card_number:
            fidelity_card_applied= True

        from .ocr_service import process_receipt_ocr, postprocess_step
        extracted_data = process_receipt_ocr(image_file)  # dict
        if not extracted_data:
            return Response({'error': f'OCR extraction failed.{extracted_data}'}, status=status.HTTP_400_BAD_REQUEST)
        processed_data = postprocess_step(
            extracted_data=extracted_data,
            fidelity_card_applied=fidelity_card_applied,
            fidelity_card_number=fidelity_card_number,
        )
        
        # Add user_id to the processed data
        processed_data['user_id'] = request.user.id

        serializer = TransactionSerializer(data=processed_data)
        if serializer.is_valid():
            transaction = serializer.save()
            return Response(TransactionSerializer(transaction).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# GET /api/transactions/
class TransactionListView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user_profile = UserProfile.objects.get(user=request.user)
        # Mongoengine queries
        if user_profile.role == 'admin':
            transactions = Transaction.objects()
        else:  # client - filter by user_id
            transactions = Transaction.objects(user_id=request.user.id)
        serializer = TransactionSerializer(transactions, many=True)
        return Response(serializer.data)

# GET /api/transactions/{id}/
class TransactionDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        user_profile = UserProfile.objects.get(user=request.user)
        transaction = Transaction.objects(id=pk).first()
        
        if not transaction:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        
        # Check if user has access to this transaction
        if user_profile.role == 'client' and transaction.user_id != request.user.id:
            return Response({'detail': 'Access denied.'}, status=status.HTTP_403_FORBIDDEN)
        
        serializer = TransactionSerializer(transaction)
        return Response(serializer.data)
