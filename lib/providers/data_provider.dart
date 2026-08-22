import 'package:flutter/material.dart';
import '../models/portfolio_photo.dart';
import '../models/professional.dart';
import '../models/professional_post.dart';
import '../models/booking.dart';
import '../models/message.dart';
import '../models/notification_model.dart';
import '../models/professional_service.dart';
import '../models/review.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';

class DataProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Professional> _professionals = [];
  List<Professional> _nearbyProfessionals = [];
  String? _profNextPageUrl;
  List<Booking> _bookings = [];
  List<ServiceRequest> _serviceRequests = [];
  List<AppNotification> _notifications = [];
  List<Conversation> _conversations = [];
  int _unreadNotifications = 0;
  int _unreadMessages = 0;
  bool _isLoading = false;
  String? _error;

  DataProvider(this._apiService);

  List<Professional> get professionals => _professionals;
  List<Professional> get nearbyProfessionals => _nearbyProfessionals;
  bool get hasMoreProfessionals => _profNextPageUrl != null;
  List<Booking> get bookings => _bookings;
  List<ServiceRequest> get serviceRequests => _serviceRequests;
  List<AppNotification> get notifications => _notifications;
  List<Conversation> get conversations => _conversations;
  int get unreadNotifications => _unreadNotifications;
  int get unreadMessages => _unreadMessages;
  int get totalUnread => _unreadNotifications + _unreadMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfessionals({
    double? lat,
    double? lng,
    int? serviceId,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sortBy,
    String? query,
    bool loadMore = false,
  }) async {
    if (loadMore && _profNextPageUrl == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Response<dynamic> response;

      if (loadMore && _profNextPageUrl != null) {
        // Use full URL returned by paginator
        response = await _apiService.dio.get(_profNextPageUrl!);
      } else {
        final queryParams = <String, dynamic>{};
        if (lat != null && lng != null) {
          queryParams['lat'] = lat;
          queryParams['lng'] = lng;
        }
        if (serviceId != null) queryParams['service_id'] = serviceId;
        if (minPrice != null) queryParams['min_price'] = minPrice;
        if (maxPrice != null) queryParams['max_price'] = maxPrice;
        if (minRating != null) queryParams['min_rating'] = minRating;
        if (sortBy != null) queryParams['sort_by'] = sortBy;
        if (query != null && query.isNotEmpty) queryParams['q'] = query;

        response = await _apiService.dio.get(
          '/professionals',
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        );
      }

      List<Professional> loadedProfessionals = [];
      String? nextUrl;

      if (response.data is Map && response.data['data'] != null) {
        loadedProfessionals = (response.data['data'] as List)
            .map((i) => Professional.fromJson(i))
            .toList();
        nextUrl = response.data['links']?['next'] ?? response.data['next_page_url'];
      } else if (response.data is List) {
        loadedProfessionals = (response.data as List)
            .map((i) => Professional.fromJson(i))
            .toList();
      }

      if (lat != null && lng != null) {
        _nearbyProfessionals = loadedProfessionals;
      } else if (loadMore) {
        _professionals = [..._professionals, ...loadedProfessionals];
        _profNextPageUrl = nextUrl;
      } else {
        _professionals = loadedProfessionals;
        _profNextPageUrl = nextUrl;
      }
    } on DioException catch (e) {
      _error = 'Failed to fetch professionals: ${e.message}';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(filePath),
      });
      await _apiService.dio.post('/user/profile-photo', data: formData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      await _apiService.dio.put('/user/profile', data: {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      return true;
    } catch (e) {
      return false;
    }
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

  // ─── Follows & activity feed ──────────────────────────────────────────────

  List<Professional> _followed = [];
  List<ProfessionalPost> _followedFeed = [];
  bool _followLoading = false;

  List<Professional> get followed => _followed;
  List<ProfessionalPost> get followedFeed => _followedFeed;
  bool get followLoading => _followLoading;

  Future<bool> followProfessional(int id) async {
    try {
      await _apiService.dio.post('/professionals/$id/follow');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unfollowProfessional(int id) async {
    try {
      await _apiService.dio.delete('/professionals/$id/follow');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchFollowed() async {
    _followLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get('/followed');
      final list = (response.data['data'] ?? response.data) as List;
      _followed = list.map((i) => Professional.fromJson(i)).toList();
    } catch (_) {
      _followed = [];
    }
    _followLoading = false;
    notifyListeners();
  }

  /// [type] one of 'offer' | 'update' | 'style'; null for the "All" tab.
  Future<void> fetchFollowedFeed({String? type}) async {
    _followLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.dio.get(
        '/followed/feed',
        queryParameters: type != null ? {'type': type} : null,
      );
      final data = response.data['data'] ?? response.data;
      final list = (data is List ? data : []) as List;
      _followedFeed = list.map((i) => ProfessionalPost.fromJson(i)).toList();
    } catch (_) {
      _followedFeed = [];
    }
    _followLoading = false;
    notifyListeners();
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

  Future<List<PortfolioPhoto>> fetchProfessionalPortfolio(int professionalId) async {
    try {
      final response = await _apiService.dio.get('/professionals/$professionalId/portfolio');
      final raw = response.data['data'] ?? response.data;
      return (raw as List).map((i) => PortfolioPhoto.fromJson(i)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Review>> fetchProfessionalReviews(int professionalId) async {
    try {
      final response = await _apiService.dio.get('/professionals/$professionalId/reviews');
      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((i) => Review.fromJson(i))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _apiService.dio.post('/reviews', data: {
        'booking_id': bookingId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      });
      await fetchBookings();
      return true;
    } catch (e) {
      return false;
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

  Future<bool> cancelBooking(int bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.dio.patch('/bookings/$bookingId/status', data: {
        'status': 'cancelled',
      });
      await fetchBookings();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to cancel booking';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to cancel booking';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Open service requests ─────────────────────────────────────────────────

  Future<void> fetchMyServiceRequests() async {
    try {
      final response = await _apiService.dio.get('/service-requests/my');
      final raw = response.data['data'] ?? response.data;
      _serviceRequests =
          (raw as List).map((i) => ServiceRequest.fromJson(i)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch service requests error: $e');
    }
  }

  Future<bool> createServiceRequest({
    int? serviceId,
    String? description,
    required String customerAddress,
    required double customerLatitude,
    required double customerLongitude,
    required String requestedDate,
    required String requestedTime,
    double radiusKm = 25,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.dio.post('/service-requests', data: {
        if (serviceId != null) 'service_id': serviceId,
        if (description != null && description.isNotEmpty) 'description': description,
        'customer_address': customerAddress,
        'customer_latitude': customerLatitude,
        'customer_longitude': customerLongitude,
        'requested_date': requestedDate,
        'requested_time': requestedTime,
        'radius_km': radiusKm,
      });
      await fetchMyServiceRequests();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to post request';
      return false;
    } catch (_) {
      _error = 'An error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelServiceRequest(int id) async {
    try {
      await _apiService.dio.patch('/service-requests/$id/cancel');
      await fetchMyServiceRequests();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> acceptServiceRequestResponse(int requestId, int responseId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.dio.post(
          '/service-requests/$requestId/responses/$responseId/accept');
      await fetchMyServiceRequests();
      await fetchBookings();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data['message'] ?? 'Failed to accept';
      return false;
    } catch (_) {
      _error = 'An error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Notifications ────────────────────────────────────────────────────────────

  Future<void> fetchNotifications() async {
    try {
      final response = await _apiService.dio.get('/notifications');
      final raw = response.data['data'] ?? response.data;
      _notifications = (raw as List).map((i) => AppNotification.fromJson(i)).toList();
      _unreadNotifications = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch notifications error: $e');
    }
  }

  Future<void> fetchUnreadCounts() async {
    try {
      final results = await Future.wait([
        _apiService.dio.get('/notifications/unread-count'),
        _apiService.dio.get('/messages/unread-count'),
      ]);
      _unreadNotifications = results[0].data['count'] ?? 0;
      _unreadMessages = results[1].data['count'] ?? 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> markNotificationRead(int id) async {
    try {
      await _apiService.dio.patch('/notifications/$id/read');
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx != -1 && !_notifications[idx].isRead) {
        _unreadNotifications = (_unreadNotifications - 1).clamp(0, 9999);
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      await _apiService.dio.patch('/notifications/read-all');
      _unreadNotifications = 0;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Messages ──────────────────────────────────────────────────────────────

  Future<void> fetchConversations() async {
    try {
      final response = await _apiService.dio.get('/messages/conversations');
      final raw = response.data['data'] ?? response.data;
      _conversations = (raw as List).map((i) => Conversation.fromJson(i)).toList();
      _unreadMessages = _conversations.fold(0, (sum, c) => sum + c.unreadCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch conversations error: $e');
    }
  }

  Future<List<Message>> fetchConversation(int otherUserId) async {
    try {
      final response = await _apiService.dio.get('/messages/$otherUserId');
      final raw = response.data['data'] ?? response.data;
      final messages = (raw as List).map((i) => Message.fromJson(i)).toList();
      // Refresh unread counts after viewing
      fetchUnreadCounts();
      return messages;
    } catch (e) {
      return [];
    }
  }

  Future<bool> sendMessage({
    required int receiverId,
    required String content,
    int? bookingId,
  }) async {
    try {
      await _apiService.dio.post('/messages', data: {
        'receiver_id': receiverId,
        'content': content,
        if (bookingId != null) 'booking_id': bookingId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> createBooking({
    required int professionalId,
    int? serviceId,
    int? professionalServiceId,
    required String date,
    required String time,
    required double totalPrice,
    String type = 'booking',
    String? venueType,
    String? customerAddress,
    double? customerLatitude,
    double? customerLongitude,
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
        'type': type,
        if (venueType != null) 'venue_type': venueType,
        if (customerAddress != null && customerAddress.isNotEmpty)
          'customer_address': customerAddress,
        if (customerLatitude != null) 'customer_latitude': customerLatitude,
        if (customerLongitude != null) 'customer_longitude': customerLongitude,
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
