import 'package:flutter/material.dart';
import '../models/professional.dart';

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback onTap;

  const ProfessionalCard({
    super.key,
    required this.professional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(professional.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(professional.category),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(professional.location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        trailing: Text(
          professional.priceRange,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: onTap,
      ),
    );
  }
}
