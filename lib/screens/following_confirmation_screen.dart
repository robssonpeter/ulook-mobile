import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';
import '../models/professional.dart';

/// Shown right after a customer follows a professional (mock-up screen 6).
class FollowingConfirmationScreen extends StatelessWidget {
  final Professional professional;
  const FollowingConfirmationScreen({super.key, required this.professional});

  @override
  Widget build(BuildContext context) {
    final pro = professional;
    final hasCoords = pro.latitude != null && pro.longitude != null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE7F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Color(0xFFEC4899), size: 52),
              ),
              const SizedBox(height: 22),
              Text(
                'You are now following\n${pro.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextDark,
                    height: 1.3),
              ),
              const SizedBox(height: 10),
              Text(
                "You'll receive updates, offers and new styles from this professional.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 28),
              // Map preview + address card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEDE6DF)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: hasCoords
                          ? FlutterMap(
                              options: MapOptions(
                                initialCenter:
                                    LatLng(pro.latitude!, pro.longitude!),
                                initialZoom: 14,
                                interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.yuluk.app',
                                ),
                                MarkerLayer(markers: [
                                  Marker(
                                    point:
                                        LatLng(pro.latitude!, pro.longitude!),
                                    child: const Icon(Icons.location_pin,
                                        color: kPrimary, size: 36),
                                  ),
                                ]),
                              ],
                            )
                          : Container(
                              color: kPrimarySoft,
                              child: const Center(
                                child: Icon(Icons.map_outlined,
                                    color: kPrimary, size: 40),
                              ),
                            ),
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kPrimarySoft,
                        backgroundImage: pro.profilePhotoUrl != null
                            ? CachedNetworkImageProvider(pro.profilePhotoUrl!)
                            : null,
                        child: pro.profilePhotoUrl == null
                            ? const Icon(Icons.store_rounded, color: kPrimary)
                            : null,
                      ),
                      title: Text(pro.name,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(pro.location),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
