import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'professional_bookings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<DataProvider>().fetchBookings(asProfessional: true);
  }

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<DataProvider>().bookings;
    final isLoading = context.watch<DataProvider>().isLoading;

    final pendingCount = bookings.where((b) => b.status == 'pending').length;
    final confirmedCount = bookings.where((b) => b.status == 'confirmed').length;
    final totalCount = bookings.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Professional Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading && bookings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildStatCard('Total Bookings', totalCount.toString(), Colors.blue),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Pending', pendingCount.toString(), Colors.orange)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Confirmed', confirmedCount.toString(), Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProfessionalBookingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Manage Bookings'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
