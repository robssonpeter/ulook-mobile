import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';

class BecomeProfessionalScreen extends StatefulWidget {
  const BecomeProfessionalScreen({super.key});

  @override
  State<BecomeProfessionalScreen> createState() => _BecomeProfessionalScreenState();
}

class _BecomeProfessionalScreenState extends State<BecomeProfessionalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceRangeController = TextEditingController();
  List<int> _selectedServices = [];
  List<Map<String, dynamic>> _availableServices = [];
  bool _isLoadingServices = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await context.read<DataProvider>().fetchServices();
    setState(() {
      _availableServices = services;
      _isLoadingServices = false;
    });
  }

  @override
  void dispose() {
    _bioController.dispose();
    _locationController.dispose();
    _priceRangeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    final success = await context.read<DataProvider>().becomeProfessional(
      bio: _bioController.text,
      location: _locationController.text,
      priceRange: _priceRangeController.text,
      services: _selectedServices,
    );

    if (success && mounted) {
      await context.read<AuthProvider>().refreshUser();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Success! You are now a professional.')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<DataProvider>().error ?? 'Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Professional')),
      body: _isLoadingServices
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio', hintText: 'Tell us about your expertise'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Location', hintText: 'City or Area'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceRangeController,
                      decoration: const InputDecoration(labelText: 'Price Range', hintText: 'e.g. \$\$ - \$\$\$'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _availableServices.map((service) {
                        final id = service['id'] as int;
                        final isSelected = _selectedServices.contains(id);
                        return FilterChip(
                          label: Text(service['name']),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedServices.add(id);
                              } else {
                                _selectedServices.remove(id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: context.watch<DataProvider>().isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: context.watch<DataProvider>().isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Register as Professional'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
