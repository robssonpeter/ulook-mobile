import 'package:flutter/material.dart';

/// A bookable service category shown as a photo tile on the home screen.
class ServiceCategory {
  final String label;

  /// Keyword used both to search professionals (`q=`) and to match a
  /// professional's `category` field client-side.
  final String keyword;

  /// Free, keyword-based stock photo (LoremFlickr — no API key needed).
  final String imageUrl;

  /// Fallback icon shown while the photo loads or if it fails.
  final IconData icon;

  /// Accent colour used for the fallback tile and soft fills.
  final Color accent;

  const ServiceCategory({
    required this.label,
    required this.keyword,
    required this.imageUrl,
    required this.icon,
    required this.accent,
  });
}

/// The ten service categories from the product roadmap.
const kServiceCategories = <ServiceCategory>[
  ServiceCategory(
    label: 'Men Grooming & Barber',
    keyword: 'barber',
    imageUrl: 'https://loremflickr.com/600/400/barber',
    icon: Icons.content_cut_rounded,
    accent: Color(0xFF6D4C41),
  ),
  ServiceCategory(
    label: 'Hair Styling',
    keyword: 'hair',
    imageUrl: 'https://loremflickr.com/600/400/hairstyle,salon',
    icon: Icons.brush_rounded,
    accent: Color(0xFFC99A3F),
  ),
  ServiceCategory(
    label: 'Braiding Specialists',
    keyword: 'braids',
    imageUrl: 'https://loremflickr.com/600/400/braids,hair',
    icon: Icons.waves_rounded,
    accent: Color(0xFF8D6E63),
  ),
  ServiceCategory(
    label: 'Makeup Artists',
    keyword: 'makeup',
    imageUrl: 'https://loremflickr.com/600/400/makeup',
    icon: Icons.face_retouching_natural_rounded,
    accent: Color(0xFFEC4899),
  ),
  ServiceCategory(
    label: 'Nail Technicians',
    keyword: 'nails',
    imageUrl: 'https://loremflickr.com/600/400/manicure,nails',
    icon: Icons.back_hand_rounded,
    accent: Color(0xFFF472B6),
  ),
  ServiceCategory(
    label: 'Beauty Therapists',
    keyword: 'facial',
    imageUrl: 'https://loremflickr.com/600/400/facial,beauty',
    icon: Icons.face_rounded,
    accent: Color(0xFFA855F7),
  ),
  ServiceCategory(
    label: 'Massage Therapists',
    keyword: 'massage',
    imageUrl: 'https://loremflickr.com/600/400/massage,therapy',
    icon: Icons.self_improvement_rounded,
    accent: Color(0xFF0891B2),
  ),
  ServiceCategory(
    label: 'Spas',
    keyword: 'spa',
    imageUrl: 'https://loremflickr.com/600/400/spa,wellness',
    icon: Icons.spa_rounded,
    accent: Color(0xFF14B8A6),
  ),
  ServiceCategory(
    label: 'Bridal Specialists',
    keyword: 'bridal',
    imageUrl: 'https://loremflickr.com/600/400/bridal,wedding',
    icon: Icons.diamond_rounded,
    accent: Color(0xFFBE185D),
  ),
  ServiceCategory(
    label: 'Kids Hair Specialists',
    keyword: 'kids hair',
    imageUrl: 'https://loremflickr.com/600/400/kids,haircut',
    icon: Icons.child_care_rounded,
    accent: Color(0xFF059669),
  ),
];
