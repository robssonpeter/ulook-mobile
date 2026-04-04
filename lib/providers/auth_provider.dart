import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> tryAutoLogin() async {
    final token = await _apiService.getToken();
    if (token != null) {
      // In a real app, you might want to fetch user profile here
      // For MVP, we can assume we're logged in if we have a token
      // or implement a /me endpoint
    }
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/login', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        _user = User.fromJson(response.data['user']);
        await _apiService.saveToken(token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final Map<String, dynamic> errors = e.response?.data['errors'];
        _error = errors.values.map((v) => (v as List).join('\n')).join('\n');
      } else {
        _error = e.response?.data['message'] ?? 'Login failed';
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final token = response.data['access_token'];
        _user = User.fromJson(response.data['user']);
        await _apiService.saveToken(token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final Map<String, dynamic> errors = e.response?.data['errors'];
        _error = errors.values.map((v) => (v as List).join('\n')).join('\n');
      } else {
        _error = e.response?.data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiService.dio.post('/logout');
    } catch (e) {
      // Ignore logout errors
    } finally {
      _user = null;
      await _apiService.deleteToken();
      notifyListeners();
    }
  }
}
