import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/professional_card.dart';
import 'professional_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<DataProvider>().fetchProfessionals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Professionals')),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.isLoading && data.professionals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (data.error != null && data.professionals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data.error!),
                  ElevatedButton(
                    onPressed: () => data.fetchProfessionals(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (data.professionals.isEmpty) {
            return const Center(child: Text('No professionals found.'));
          }

          return RefreshIndicator(
            onRefresh: () => data.fetchProfessionals(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.professionals.length,
              itemBuilder: (context, index) {
                final professional = data.professionals[index];
                return ProfessionalCard(
                  professional: professional,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProfessionalProfileScreen(id: professional.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
