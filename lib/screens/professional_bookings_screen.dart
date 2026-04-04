import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/booking.dart';

class ProfessionalBookingsScreen extends StatefulWidget {
  const ProfessionalBookingsScreen({super.key});

  @override
  State<ProfessionalBookingsScreen> createState() => _ProfessionalBookingsScreenState();
}

class _ProfessionalBookingsScreenState extends State<ProfessionalBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    await context.read<DataProvider>().fetchBookings(asProfessional: true);
  }

  Future<void> _updateStatus(int bookingId, String status) async {
    final success = await context.read<DataProvider>().updateBookingStatus(bookingId, status);
    if (success) {
      _loadBookings();
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<DataProvider>().error ?? 'Failed to update status')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<DataProvider>().bookings;
    final isLoading = context.watch<DataProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: RefreshIndicator(
        onRefresh: _loadBookings,
        child: isLoading && bookings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Service: ${booking.serviceName}'),
                          Text('Date: ${booking.bookingDate} at ${booking.bookingTime}'),
                          Text('Price: \$${booking.totalPrice}'),
                          const Divider(),
                          if (booking.status == 'pending')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _updateStatus(booking.id, 'cancelled'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Reject'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _updateStatus(booking.id, 'confirmed'),
                                  child: const Text('Accept'),
                                ),
                              ],
                            )
                          else if (booking.status == 'confirmed')
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => _updateStatus(booking.id, 'completed'),
                                child: const Text('Mark as Completed'),
                              ),
                            ),
                          if (booking.status != 'cancelled' && booking.status != 'completed' && booking.status != 'pending')
                             Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => _updateStatus(booking.id, 'cancelled'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Cancel Booking'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending': color = Colors.orange; break;
      case 'confirmed': color = Colors.green; break;
      case 'completed': color = Colors.blue; break;
      case 'cancelled': color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
