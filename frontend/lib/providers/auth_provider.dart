import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  UserProfile? _userProfile;
  String? _token;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get userProfile => _userProfile;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _userProfile != null;

  // Initialize auth state
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storedToken = await _storage.read(key: 'auth_token');
      if (storedToken != null) {
        _token = storedToken;
        await _loadUserProfile();
      }
    } catch (e) {
      _error = 'Failed to restore session: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);
      
      if (response.containsKey('access')) {
        _token = response['access'];
        await _storage.write(key: 'auth_token', value: _token);
        await _loadUserProfile();
        return true;
      } else {
        _error = 'Invalid response from server';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.register(
        username: username,
        email: email,
        password: password,
      );
      
      // Auto-login after successful registration
      return await login(username, password);
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      if (_token != null) {
        _userProfile = await ApiService.getUserProfile(_token!);
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
      await logout(); // Clear invalid token
    }
  }

  // Logout
  Future<void> logout() async {
    _userProfile = null;
    _token = null;
    _error = null;
    
    await _storage.delete(key: 'auth_token');
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
