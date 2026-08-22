import 'package:flutter/material.dart';
import '../main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'map_view_screen.dart';

class OpenRequestScreen extends StatefulWidget {
  const OpenRequestScreen({super.key});

  @override
  State<OpenRequestScreen> createState() => _OpenRequestScreenState();
}

class _OpenRequestScreenState extends State<OpenRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  double? _lat;
  double? _lng;
  bool _locating = false;
  double _radiusKm = 25;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
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
      if (mounted) setState(() { _lat = pos.latitude; _lng = pos.longitude; });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Could not get location')));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture your GPS location')),
      );
      return;
    }

    final ok = await context.read<DataProvider>().createServiceRequest(
      description: _descController.text.trim(),
      customerAddress: _addressController.text.trim(),
      customerLatitude: _lat!,
      customerLongitude: _lng!,
      requestedDate: DateFormat('yyyy-MM-dd').format(_date),
      requestedTime:
          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
      radiusKm: _radiusKm,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Request posted! Nearby professionals will respond.')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                context.read<DataProvider>().error ?? 'Failed to post request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kSecondarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kSecondary.withOpacity(0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.broadcast_on_personal, color: kSecondary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your request will be sent to nearby professionals. '
                        'Review their responses and choose one.',
                        style: TextStyle(color: kSecondary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Address
              const Text('Your Address',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Street, area, city…',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Address is required' : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _lat != null
                          ? 'GPS: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                          : 'Location required for matching',
                      style: TextStyle(
                          fontSize: 12,
                          color: _lat != null ? Colors.green : Colors.red),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _locating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : ElevatedButton.icon(
                          onPressed: _captureLocation,
                          icon: const Icon(Icons.my_location, size: 16),
                          label: const Text('GPS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked =
                          await Navigator.of(context).push<MapPickResult>(
                        MaterialPageRoute(
                          builder: (_) => MapLocationPickerScreen(
                            initial: _lat != null
                                ? LatLng(_lat!, _lng!)
                                : null,
                          ),
                        ),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _lat = picked.latLng.latitude;
                          _lng = picked.latLng.longitude;
                          if (picked.address != null &&
                              _addressController.text.isEmpty) {
                            _addressController.text = picked.address!;
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search radius
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Search Radius',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${_radiusKm.toInt()} km',
                      style: const TextStyle(
                          color: kSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
              Slider(
                value: _radiusKm,
                min: 5,
                max: 100,
                divisions: 19,
                activeColor: kSecondary,
                label: '${_radiusKm.toInt()} km',
                onChanged: (v) => setState(() => _radiusKm = v),
              ),
              const SizedBox(height: 8),

              // Date & Time
              const Text('When do you need it?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd MMM yyyy').format(_date)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_time.format(context)),
                            const Icon(Icons.access_time, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              const Text('What do you need?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText:
                      'e.g. Hair braiding, natural hair, about 2 hours…',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              Consumer<DataProvider>(
                builder: (_, data, __) => data.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: const Text('Post Request'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: kSecondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
