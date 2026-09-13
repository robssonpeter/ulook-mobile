import 'package:dio/dio.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'professional_profile_screen.dart';

class MapPickResult {
  final LatLng latLng;
  final String? address;
  const MapPickResult(this.latLng, {this.address});
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(-1.2921, 36.8219); // Nairobi default
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        if (mounted) setState(() => _locationLoaded = true);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          _locationLoaded = true;
        });
        _mapController.move(_center, 13.0);
      }
    } catch (_) {
      if (mounted) setState(() => _locationLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Professionals')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          final professionals = data.professionals
              .where((p) => p.latitude != null && p.longitude != null)
              .toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yuluk.app',
              ),
              if (_locationLoaded)
                MarkerLayer(
                  markers: [
                    // User location marker
                    Marker(
                      point: _center,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    // Professional markers
                    ...professionals.map((pro) => Marker(
                          point: LatLng(pro.latitude!, pro.longitude!),
                          width: 160,
                          height: 60,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProfessionalProfileScreen(id: pro.id),
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kPrimary,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                          offset: Offset(0, 2))
                                    ],
                                  ),
                                  child: Text(
                                    pro.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.location_pin,
                                    color: kPrimary, size: 20),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'My location',
        onPressed: () {
          if (_locationLoaded) _mapController.move(_center, 14.0);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

// ─── Reusable map location picker ─────────────────────────────────────────────

/// Push this screen to let the user tap the map to pick a location.
/// Returns a [LatLng] or null if cancelled.
class MapLocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const MapLocationPickerScreen({super.key, this.initial});

  @override
  State<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _picked;
  String? _address;
  bool _locating = false;
  bool _geocoding = false;

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _geocoding = true);
    try {
      final resp = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {'lat': point.latitude, 'lon': point.longitude, 'format': 'json'},
        options: Options(headers: {'User-Agent': 'YulukApp/1.0'}),
      );
      if (mounted) setState(() => _address = resp.data['display_name'] as String?);
    } catch (_) {
      if (mounted) setState(() => _address = null);
    } finally {
      if (mounted) setState(() => _geocoding = false);
    }
  }

  Future<void> _useGps() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) { return; }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (mounted) {
        final ll = LatLng(pos.latitude, pos.longitude);
        setState(() { _picked = ll; _address = null; });
        _mapController.move(ll, 15.0);
        _reverseGeocode(ll);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ??
        widget.initial ??
        const LatLng(-1.2921, 36.8219);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: _picked != null
                ? () => Navigator.of(context)
                    .pop(MapPickResult(_picked!, address: _address))
                : null,
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.0,
              onTap: (_, point) {
                setState(() { _picked = point; _address = null; });
                _reverseGeocode(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yuluk.app',
              ),
              if (_picked != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _picked!,
                      width: 40,
                      height: 48,
                      child: const Icon(Icons.location_pin,
                          color: kSecondary, size: 48),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Tap the map to set your location',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
          ),
          if (_picked != null)
            Positioned(
              bottom: 96,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _geocoding
                      ? const Center(
                          child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2)))
                      : Text(
                          _address ??
                              '${_picked!.latitude.toStringAsFixed(5)}, '
                                  '${_picked!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _locating ? null : _useGps,
        backgroundColor: kSecondary,
        foregroundColor: Colors.white,
        icon: _locating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.my_location),
        label: const Text('Use GPS'),
      ),
    );
  }
}
