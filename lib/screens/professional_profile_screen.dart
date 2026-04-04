import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/professional.dart';
import '../providers/data_provider.dart';
import 'booking_screen.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final int id;

  const ProfessionalProfileScreen({super.key, required this.id});

  @override
  State<ProfessionalProfileScreen> createState() => _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  Professional? _professional;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfessional();
  }

  Future<void> _loadProfessional() async {
    final pro = await context.read<DataProvider>().fetchProfessionalDetail(widget.id);
    if (mounted) {
      setState(() {
        _professional = pro;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_professional == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Professional not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_professional!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              _professional!.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _professional!.category,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_professional!.location),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_professional!.bio),
            const SizedBox(height: 24),
            const Text(
              'Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_professional!.services == null || _professional!.services!.isEmpty)
              const Text('No services listed.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _professional!.services!.length,
                itemBuilder: (context, index) {
                  final service = _professional!.services![index];
                  return ListTile(
                    title: Text(service.name),
                    subtitle: Text(service.description),
                    trailing: Text('\$${service.price.toStringAsFixed(2)}'),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BookingScreen(professional: _professional!),
              ),
            );
          },
          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          child: const Text('Book Appointment'),
        ),
      ),
    );
  }
}
