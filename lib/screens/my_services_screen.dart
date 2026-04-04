import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/auth_provider.dart';
import '../models/professional_service.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  List<ProfessionalService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // We need the professional profile ID. For simplicity, we assume we can fetch it or find it.
    // In a real app, the user object might have professional_id or we fetch it first.
    final dataProvider = context.read<DataProvider>();
    
    // We'll use a hacky way to find the professional ID for this user if not available
    // In this MVP, we can fetch all and find the one matching user.id
    await dataProvider.fetchProfessionals();
    final pro = dataProvider.professionals.firstWhere((p) => true); // Placeholder

    final services = await dataProvider.fetchProfessionalServices(pro.id);
    if (mounted) {
      setState(() {
        _services = services;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddService(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('No services in your catalog.'))
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: ListView.builder(
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(service.name ?? service.service?.name ?? 'Unknown Service'),
                          subtitle: Text('${service.price.toStringAsFixed(2)} - ${service.durationMinutes ?? 0} mins'),
                          trailing: Switch(
                            value: service.isActive,
                            onChanged: (value) async {
                              final success = await context.read<DataProvider>().toggleProfessionalService(service.id);
                              if (success) _loadServices();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _navigateToAddService() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddServiceScreen()),
    ).then((_) => _loadServices());
  }
}

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedServiceId;
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    final services = await context.read<DataProvider>().fetchServices();
    setState(() {
      _availableServices = services;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Service')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                decoration: const InputDecoration(labelText: 'Select Base Service'),
                items: _availableServices.map((s) {
                  return DropdownMenuItem<int>(
                    value: s['id'],
                    child: Text(s['name']),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedServiceId = val),
                validator: (val) => val == null ? 'Please select a service' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Custom Name (Optional)'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (Minutes)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add to Catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<DataProvider>().addProfessionalService(
      serviceId: _selectedServiceId!,
      name: _nameController.text.isEmpty ? null : _nameController.text,
      price: double.parse(_priceController.text),
      durationMinutes: _durationController.text.isEmpty ? null : int.parse(_durationController.text),
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}
