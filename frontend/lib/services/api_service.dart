import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/transaction.dart';
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;
  
  // Headers for authenticated requests
  static Map<String, String> _getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.loginUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    String role = 'client',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.registerUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user': {
            'username': username,
            'email': email,
            'password': password,
          },
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user profile
  static Future<UserProfile> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.userProfileUrl}'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get transactions
  static Future<List<Transaction>> getTransactions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.transactionsUrl}'),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get transactions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Process receipt (upload image for OCR)
  static Future<Transaction> processReceipt({
    required String token,
    required File imageFile,
    String? fidelityCardNumber,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConstants.receiptProcessUrl}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      
      request.files.add(
         await http.MultipartFile.fromPath(
                  'image',
                  imageFile.path,
      ),);

      if (fidelityCardNumber != null && fidelityCardNumber.isNotEmpty) {
        request.fields['fidelity_card_number'] = fidelityCardNumber;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return Transaction.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to process receipt: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
