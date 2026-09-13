import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/service_request.dart';
import '../providers/data_provider.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'open_request_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DataProvider>().fetchMyServiceRequests();
    });
  }

  Future<void> _cancel(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Cancel this open request? Professionals will no longer see it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context.read<DataProvider>().cancelServiceRequest(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? 'Request cancelled.' : 'Failed to cancel.')),
        );
      }
    }
  }

  Future<void> _accept(int requestId, int responseId, String proName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Professional'),
        content: Text('Accept $proName for this job? A booking will be created automatically.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kSecondary),
            child: const Text('Yes, Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final ok = await context
          .read<DataProvider>()
          .acceptServiceRequestResponse(requestId, responseId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Booking confirmed with $proName!'
                : 'Failed to accept. Try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Post new request',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OpenRequestScreen()),
              );
              if (mounted) context.read<DataProvider>().fetchMyServiceRequests();
            },
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isLoading && data.serviceRequests.isEmpty) {
            return const AppSkeletonList(itemHeight: 140);
          }

          if (data.serviceRequests.isEmpty) {
            return EmptyState(
              icon: Icons.broadcast_on_personal_outlined,
              title: 'No open requests yet',
              subtitle: 'Post a request and let nearby professionals come to you.',
              actionLabel: 'Post a Request',
              actionIcon: Icons.add_rounded,
              onAction: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const OpenRequestScreen()),
                      );
                      if (mounted) {
                        context.read<DataProvider>().fetchMyServiceRequests();
                      }
                    },
            );
          }

          return RefreshIndicator(
            onRefresh: () => data.fetchMyServiceRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: data.serviceRequests.length,
              itemBuilder: (context, index) {
                return _RequestCard(
                  request: data.serviceRequests[index],
                  onCancel: () => _cancel(data.serviceRequests[index].id),
                  onAccept: (responseId, proName) => _accept(
                      data.serviceRequests[index].id, responseId, proName),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─── Request card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatefulWidget {
  final ServiceRequest request;
  final VoidCallback onCancel;
  final void Function(int responseId, String proName) onAccept;

  const _RequestCard({
    required this.request,
    required this.onCancel,
    required this.onAccept,
  });

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _expanded = false;

  Color get _statusColor {
    switch (widget.request.status) {
      case 'open':
        return kSecondary;
      case 'matched':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;
    final hasResponses = req.responses.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.broadcast_on_personal,
                    color: kSecondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    req.serviceName ?? req.description ?? 'Home Service Request',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StatusBadge(status: req.status, color: _statusColor),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(req.customerAddress,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${req.requestedDate}  ${req.requestedTime}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(width: 12),
                const Icon(Icons.radar, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${req.radiusKm.toInt()} km radius',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
            if (req.description != null && req.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(req.description!,
                  style: const TextStyle(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],

            // Mini map
            if (req.customerLatitude != 0 || req.customerLongitude != 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 130,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                          req.customerLatitude, req.customerLongitude),
                      initialZoom: 14,
                      interactionOptions:
                          const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.yuluk.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(req.customerLatitude,
                                req.customerLongitude),
                            width: 36,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: kSecondary, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Responses summary
            const SizedBox(height: 10),
            if (req.isOpen) ...[
              InkWell(
                onTap: hasResponses ? () => setState(() => _expanded = !_expanded) : null,
                child: Row(
                  children: [
                    Icon(
                      hasResponses ? Icons.people : Icons.hourglass_empty,
                      size: 16,
                      color: hasResponses ? kSecondary : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasResponses
                          ? '${req.responses.length} professional${req.responses.length == 1 ? '' : 's'} responded — tap to view'
                          : 'Waiting for professionals to respond…',
                      style: TextStyle(
                        color: hasResponses ? kSecondary : Colors.grey,
                        fontSize: 13,
                        fontWeight: hasResponses ? FontWeight.w600 : null,
                      ),
                    ),
                    if (hasResponses) ...[
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: kSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (_expanded && hasResponses) ...[
                const SizedBox(height: 10),
                const Divider(),
                ...req.responses.map((r) => _ResponseTile(
                      response: r,
                      onAccept: () =>
                          widget.onAccept(r.id, r.professionalName ?? 'Professional'),
                    )),
              ],
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.cancel_outlined, size: 16),
                  label: const Text('Cancel Request'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ] else if (req.isMatched) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Text('Booking confirmed! Check your Bookings tab.',
                        style:
                            TextStyle(color: Colors.green, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResponseTile extends StatelessWidget {
  final ServiceRequestResponse response;
  final VoidCallback onAccept;

  const _ResponseTile({required this.response, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          response.professionalPhotoUrl != null
              ? CircleAvatar(
                  radius: 22,
                  backgroundImage:
                      NetworkImage(response.professionalPhotoUrl!),
                )
              : CircleAvatar(
                  radius: 22,
                  backgroundColor: kSecondarySoft,
                  child: Text(
                    (response.professionalName ?? 'P')[0].toUpperCase(),
                    style: const TextStyle(color: kSecondary),
                  ),
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(response.professionalName ?? 'Professional',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (response.professionalLocation != null)
                  Text(response.professionalLocation!,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                Row(
                  children: [
                    ...List.generate(
                        5,
                        (i) => Icon(
                              i < response.professionalRating.floor()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 12,
                              color: Colors.amber,
                            )),
                    const SizedBox(width: 4),
                    Text('(${response.professionalReviewsCount})',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
                if (response.message != null &&
                    response.message!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('"${response.message}"',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey)),
                ],
                const SizedBox(height: 4),
                Text('\$${response.priceOffered.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 13)),
              ),
              if (response.professionalUserId != null) ...[
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        otherUserId: response.professionalUserId!,
                        otherUserName:
                            response.professionalName ?? 'Professional',
                        otherUserPhotoUrl: response.professionalPhotoUrl,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Chat', style: TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
