import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
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
    final cs = Theme.of(context).colorScheme;
    final pro = professional;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: pro.profilePhotoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: pro.profilePhotoUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Shimmer.fromColors(
                          baseColor: const Color(0xFFEEEFF3),
                          highlightColor: Colors.white,
                          child: Container(
                            width: 72,
                            height: 72,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (_, __, ___) =>
                            _AvatarFallback(name: pro.name, primary: cs.primary),
                      )
                    : _AvatarFallback(name: pro.name, primary: cs.primary),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: cs.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pro.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ..._stars(pro.averageRating),
                        const SizedBox(width: 4),
                        Text(
                          '${pro.averageRating.toStringAsFixed(1)} (${pro.reviewsCount})',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            pro.distance != null
                                ? '${pro.distance!.toStringAsFixed(1)} km away'
                                : pro.location,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Price + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEFDF7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pro.priceRange,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Icon(Icons.chevron_right, color: Colors.grey.shade300, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _stars(double rating) {
    return List.generate(5, (i) {
      if (i < rating.floor()) {
        return const Icon(Icons.star_rounded, color: Colors.amber, size: 13);
      } else if (rating - i >= 0.5) {
        return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 13);
      } else {
        return const Icon(Icons.star_outline_rounded, color: Colors.amber, size: 13);
      }
    });
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  final Color primary;
  const _AvatarFallback({required this.name, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary.withOpacity(0.6), primary],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
