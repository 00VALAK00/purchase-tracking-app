from django.urls import path
from .views import ReceiptProcessView, TransactionListView, TransactionDetailView

urlpatterns = [
    path('receipts/process/', ReceiptProcessView.as_view(), name='receipt-process'),
    path('transactions/', TransactionListView.as_view(), name='transaction-list'),
    path('transactions/<str:pk>/', TransactionDetailView.as_view(), name='transaction-detail'),
] 