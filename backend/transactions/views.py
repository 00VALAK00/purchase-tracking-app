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
        if not image_file:
            return Response({'error': 'No image file provided.'}, status=status.HTTP_400_BAD_REQUEST)
        from .ocr_service import process_receipt_ocr
        extracted_list = process_receipt_ocr(image_file)
        if not extracted_list:
            return Response({'error': 'OCR extraction failed.'}, status=status.HTTP_400_BAD_REQUEST)
        extracted_data = extracted_list[0].dict() if hasattr(extracted_list[0], 'dict') else extracted_list[0]
        extracted_data['processed_by_user'] = str(request.user.id)
        # TODO: Run fraud detection here if needed
        serializer = TransactionSerializer(data=extracted_data)
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
        elif user_profile.role == 'fournisseur':
            transactions = Transaction.objects(store_name=user_profile.store_name)
        else:  # client
            transactions = Transaction.objects(fidelity_card_number=user_profile.fidelity_card_number)
        serializer = TransactionSerializer(transactions, many=True)
        return Response(serializer.data)

# GET /api/transactions/{id}/
class TransactionDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        transaction = Transaction.objects(id=pk).first()
        if not transaction:
            return Response({'detail': 'Not found.'}, status=status.HTTP_404_NOT_FOUND)
        serializer = TransactionSerializer(transaction)
        return Response(serializer.data)
