import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/professional.dart';
import '../models/professional_service.dart';
import '../providers/data_provider.dart';

class BookingScreen extends StatefulWidget {
  final Professional professional;
  /// 'booking' = customer goes to professional
  /// 'request' = professional comes to customer
  final String type;

  const BookingScreen({
    super.key,
    required this.professional,
    this.type = 'booking',
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ProfessionalService? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  // Request-only fields
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _locating = false;
  String? _venueType;

  bool get _isRequest => widget.type == 'request';

  @override
  void initState() {
    super.initState();
    final services = widget.professional.professionalServices;
    if (services != null && services.isNotEmpty) {
      _selectedService = services.firstWhere(
        (s) => s.isActive,
        orElse: () => services.first,
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _captureLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    if (_isRequest && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address for home service')),
      );
      return;
    }

    final provider = context.read<DataProvider>();
    final success = await provider.createBooking(
      professionalId: widget.professional.id,
      professionalServiceId: _selectedService!.id,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time:
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      totalPrice: _selectedService!.price,
      type: widget.type,
      venueType: _isRequest ? _venueType : null,
      customerAddress:
          _isRequest ? _addressController.text.trim() : null,
      customerLatitude: _isRequest ? _latitude : null,
      customerLongitude: _isRequest ? _longitude : null,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRequest
                ? 'Home service request sent!'
                : 'Appointment booked!',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Failed to submit')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRequest = _isRequest;
    return Scaffold(
      appBar: AppBar(
        title: Text(isRequest ? 'Request at Home' : 'Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isRequest
                    ? kSecondarySoft
                    : kPrimarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isRequest ? kSecondary : kPrimary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isRequest ? Icons.home_outlined : Icons.store_outlined,
                    color: isRequest ? kSecondary : kPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRequest
                              ? 'Home Service Request'
                              : 'In-Studio Booking',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRequest ? kSecondary : kPrimary,
                          ),
                        ),
                        Text(
                          isRequest
                              ? '${widget.professional.name} will come to your location'
                              : 'You will visit ${widget.professional.name}\'s location',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service selector
            const Text('Select Service',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<ProfessionalService>(
              value: _selectedService,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: widget.professional.professionalServices
                  ?.where((s) => s.isActive)
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          '${s.name ?? s.service?.name ?? 'Service'}  —  TZS ${s.price.toStringAsFixed(0)}',
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedService = v),
            ),
            const SizedBox(height: 20),

            // Date & time
            const Text('Date & Time',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                          const Icon(Icons.calendar_today, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedTime.format(context)),
                          const Icon(Icons.access_time, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Address section — only for requests
            if (isRequest) ...[
              const SizedBox(height: 20),
              const Text('Venue Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _venueType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                hint: const Text('Where should we come?'),
                items: const [
                  DropdownMenuItem(value: 'home', child: Text('Home')),
                  DropdownMenuItem(value: 'office', child: Text('Office')),
                  DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                  DropdownMenuItem(value: 'event', child: Text('Event Venue')),
                ],
                onChanged: (v) => setState(() => _venueType = v),
              ),
              const SizedBox(height: 20),
              const Text('Your Address',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Street address, city…',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _latitude != null && _longitude != null
                          ? 'GPS: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}'
                          : 'Add GPS for better accuracy (optional)',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _locating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : TextButton.icon(
                          onPressed: _captureLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('Use GPS'),
                        ),
                ],
              ),
            ],

            // Price summary
            if (_selectedService != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Price',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      'TZS ${_selectedService!.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            Consumer<DataProvider>(
              builder: (_, data, __) => data.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor:
                            isRequest ? kSecondary : kPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isRequest
                            ? 'Send Request'
                            : 'Confirm Booking',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
