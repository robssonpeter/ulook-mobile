import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'professional_profile_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(40.7128, -74.0060);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Professionals'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          Set<Marker> markers = data.professionals
              .where((pro) => pro.latitude != null && pro.longitude != null)
              .map((pro) {
            return Marker(
              markerId: MarkerId(pro.id.toString()),
              position: LatLng(pro.latitude!, pro.longitude!),
              infoWindow: InfoWindow(
                title: pro.name,
                snippet: '${pro.category} - ${pro.priceRange}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfessionalProfileScreen(id: pro.id),
                    ),
                  );
                },
              ),
            );
          }).toSet();

          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),
            markers: markers,
            myLocationEnabled: true,
          );
        },
      ),
    );
  }
}
