import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DataProvider>().fetchBookings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isLoading && data.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (data.error != null && data.bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.error!),
                  ElevatedButton(
                    onPressed: () => data.fetchBookings(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (data.bookings.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          return RefreshIndicator(
            onPressed: () => data.fetchBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.bookings.length,
              itemBuilder: (context, index) {
                final booking = data.bookings[index];
                return Card(
                  child: ListTile(
                    title: Text(booking.professional?.name ?? 'Professional'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.service?.name ?? 'Service'),
                        Text('${booking.bookingDate} at ${booking.bookingTime}'),
                      ],
                    ),
                    trailing: _buildStatusChip(booking.status),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }
}
