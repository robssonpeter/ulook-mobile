import 'package:flutter/material.dart';
import '../models/professional.dart';
import '../models/booking.dart';
import '../models/professional_service.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Professional> _professionals = [];
  List<Professional> _nearbyProfessionals = [];
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  DataProvider(this._apiService);

  List<Professional> get professionals => _professionals;
  List<Professional> get nearbyProfessionals => _nearbyProfessionals;
  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfessionals({double? lat, double? lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String path = '/professionals';
      if (lat != null && lng != null) {
        path += '?lat=$lat&lng=$lng';
      }
      
      final response = await _apiService.dio.get(path);
      List<Professional> loadedProfessionals = [];
      
      if (response.data['data'] != null) {
        loadedProfessionals = (response.data['data'] as List)
            .map((i) => Professional.fromJson(i))
            .toList();
      } else {
        loadedProfessionals = (response.data as List)
            .map((i) => Professional.fromJson(i))
            .toList();
      }

      if (lat != null && lng != null) {
        _nearbyProfessionals = loadedProfessionals;
      } else {
        _professionals = loadedProfessionals;
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
      if (response.data['data'] != null) {
        return Professional.fromJson(response.data['data']);
      }
      return Professional.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  Future<List<ProfessionalService>> fetchProfessionalServices(int professionalId) async {
    try {
      final response = await _apiService.dio.get('/professionals/$professionalId/services');
      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((i) => ProfessionalService.fromJson(i))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> addProfessionalService({
    required int serviceId,
    String? name,
    required double price,
    int? durationMinutes,
    String? description,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.post('/professional/services', data: {
        'service_id': serviceId,
        'name': name,
        'price': price,
        'duration_minutes': durationMinutes,
        'description': description,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add service to catalog';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleProfessionalService(int id) async {
    try {
      await _apiService.dio.patch('/professional/services/$id/toggle');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchBookings({bool asProfessional = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final url = asProfessional ? '/professional/bookings' : '/bookings';
      final response = await _apiService.dio.get(url);
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

  Future<bool> updateBookingStatus(int bookingId, String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.patch('/bookings/$bookingId/status', data: {
        'status': status,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update booking status';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> becomeProfessional({
    required String bio,
    required String location,
    required String priceRange,
    required List<int> services,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.post('/professionals', data: {
        'bio': bio,
        'location': location,
        'price_range': priceRange,
        'services': services,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to become a professional';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    try {
      final response = await _apiService.dio.get('/services');
      if (response.data['data'] != null) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      return [];
    }
  }

  Future<bool> createBooking({
    required int professionalId,
    int? serviceId,
    int? professionalServiceId,
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
        'professional_service_id': professionalServiceId,
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
