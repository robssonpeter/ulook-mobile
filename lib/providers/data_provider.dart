import 'package:flutter/material.dart';
import '../models/professional.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Professional> _professionals = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  DataProvider(this._apiService);

  List<Professional> get professionals => _professionals;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfessionals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/professionals');
      if (response.data['data'] != null) {
        _professionals = (response.data['data'] as List)
            .map((i) => Professional.fromJson(i))
            .toList();
      } else {
        _professionals = (response.data as List)
            .map((i) => Professional.fromJson(i))
            .toList();
      }
    } on DioException catch (e) {
      _error = 'Failed to fetch professionals: ${e.message}';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Professional?> fetchProfessionalDetail(int id) async {
    try {
      final response = await _apiService.dio.get('/professionals/$id');
      return Professional.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.get('/bookings');
      if (response.data['data'] != null) {
        _bookings = (response.data['data'] as List)
            .map((i) => Booking.fromJson(i))
            .toList();
      } else {
        _bookings = (response.data as List)
            .map((i) => Booking.fromJson(i))
            .toList();
      }
    } on DioException catch (e) {
      _error = 'Failed to fetch bookings: ${e.message}';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking({
    required int professionalId,
    required int serviceId,
    required String date,
    required String time,
    required double totalPrice,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.post('/bookings', data: {
        'professional_id': professionalId,
        'service_id': serviceId,
        'booking_date': date,
        'booking_time': time,
        'total_price': totalPrice,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create booking';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
