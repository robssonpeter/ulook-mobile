import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/professional.dart';
import '../models/professional_service.dart';
import '../providers/data_provider.dart';

class BookingScreen extends StatefulWidget {
  final Professional professional;

  const BookingScreen({super.key, required this.professional});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ProfessionalService? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    // Use first available service by default if any
    if (widget.professional.professionalServices != null && 
        widget.professional.professionalServices!.isNotEmpty) {
      _selectedService = widget.professional.professionalServices!.firstWhere((s) => s.isActive, orElse: () => widget.professional.professionalServices!.first);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() async {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final success = await dataProvider.createBooking(
      professionalId: widget.professional.id,
      professionalServiceId: _selectedService!.id,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      totalPrice: _selectedService!.price,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking successful!')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dataProvider.error ?? 'Booking failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking with ${widget.professional.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Select Service', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<ProfessionalService>(
              value: _selectedService,
              items: widget.professional.professionalServices?.where((s) => s.isActive).map((service) {
                return DropdownMenuItem(
                  value: service,
                  child: Text('${service.name ?? service.service?.name ?? 'Service'} - \$${service.price}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedService = value;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            const Text('Select Date', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Time', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 32),
            if (_selectedService != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '\$${_selectedService!.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Consumer<DataProvider>(
              builder: (context, data, _) {
                return data.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        child: const Text('Confirm Booking'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
