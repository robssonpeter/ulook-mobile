import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/fcm_service.dart';
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
    if (token == null) {
      notifyListeners();
      return;
    }
    try {
      final response = await _apiService.dio.get('/user');
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data'] ?? response.data);
      }
    } on DioException catch (e) {
      // Only clear the token when the server explicitly rejects it (401 = expired/revoked).
      // Network errors (timeout, no connection) should not log the user out.
      if (e.response?.statusCode == 401) {
        await _apiService.deleteToken();
      }
      debugPrint('Auto-login: ${e.response?.statusCode ?? 'network error'}');
    } catch (e) {
      debugPrint('Auto-login unexpected error: $e');
    }
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final response = await _apiService.dio.get('/user');
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data'] ?? response.data);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh User Error: $e');
    }
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/login', data: {
        'login': login,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        _user = User.fromJson(response.data['user']);
        await _apiService.saveToken(token);
        // Register FCM token after successful login
        _registerFcmToken();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint('Login Error: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final Map<String, dynamic> errors = e.response?.data['errors'];
        _error = errors.values.map((v) => (v as List).join('\n')).join('\n');
      } else {
        _error = e.response?.data['message'] ?? 'Login failed';
      }
    } catch (e) {
      debugPrint('Unexpected Login Error: $e');
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation, {String? phone}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post('/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
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
      debugPrint('Registration Error: ${e.response?.data}');
      if (e.response?.data != null && e.response?.data['errors'] != null) {
        final Map<String, dynamic> errors = e.response?.data['errors'];
        _error = errors.values.map((v) => (v as List).join('\n')).join('\n');
      } else {
        _error = e.response?.data['message'] ?? 'Registration failed';
      }
    } catch (e) {
      debugPrint('Unexpected Registration Error: $e');
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _registerFcmToken() async {
    try {
      final fcmToken = await FcmService.getToken();
      if (fcmToken != null) {
        await _apiService.dio.post('/user/fcm-token', data: {'token': fcmToken});
      }
    } catch (_) {}
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
