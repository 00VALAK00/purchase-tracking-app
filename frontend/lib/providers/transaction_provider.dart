import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import 'dart:io';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get total amount
  double get totalAmount {
    return _transactions.fold(0, (sum, transaction) => sum + transaction.totalAmount);
  }

  // Get transaction count
  int get transactionCount => _transactions.length;

  // Load transactions
  Future<void> loadTransactions(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await ApiService.getTransactions(token);
      _transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Process receipt (add new transaction)
  Future<bool> processReceipt({
    required String token,
    required File imageFile,
    String? fidelityCardNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTransaction = await ApiService.processReceipt(
        token: token,
        imageFile: imageFile, // This will be fixed in the service
        fidelityCardNumber: fidelityCardNumber,
      );

      // Add to beginning of list (newest first)
      _transactions.insert(0, newTransaction);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh transactions
  Future<void> refresh(String token) async {
    await loadTransactions(token);
  }
}
