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
    imageUrl: 'https://images.pexels.com/photos/8867400/pexels-photo-8867400.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.content_cut_rounded,
    accent: Color(0xFF6D4C41),
  ),
  ServiceCategory(
    label: 'Hair Styling',
    keyword: 'hair',
    imageUrl: 'https://images.pexels.com/photos/5368632/pexels-photo-5368632.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.brush_rounded,
    accent: Color(0xFFC99A3F),
  ),
  ServiceCategory(
    label: 'Braiding Specialists',
    keyword: 'braids',
    imageUrl: 'https://images.pexels.com/photos/15576674/pexels-photo-15576674.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.waves_rounded,
    accent: Color(0xFF8D6E63),
  ),
  ServiceCategory(
    label: 'Makeup Artists',
    keyword: 'makeup',
    imageUrl: 'https://images.pexels.com/photos/5149734/pexels-photo-5149734.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.face_retouching_natural_rounded,
    accent: Color(0xFFEC4899),
  ),
  ServiceCategory(
    label: 'Nail Technicians',
    keyword: 'nails',
    imageUrl: 'https://images.pexels.com/photos/16041439/pexels-photo-16041439.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.back_hand_rounded,
    accent: Color(0xFFF472B6),
  ),
  ServiceCategory(
    label: 'Beauty Therapists',
    keyword: 'facial',
    imageUrl: 'https://images.pexels.com/photos/3865548/pexels-photo-3865548.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.face_rounded,
    accent: Color(0xFFA855F7),
  ),
  ServiceCategory(
    label: 'Massage Therapists',
    keyword: 'massage',
    imageUrl: 'https://images.pexels.com/photos/6629530/pexels-photo-6629530.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.self_improvement_rounded,
    accent: Color(0xFF0891B2),
  ),
  ServiceCategory(
    label: 'Spas',
    keyword: 'spa',
    imageUrl: 'https://images.pexels.com/photos/9146381/pexels-photo-9146381.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.spa_rounded,
    accent: Color(0xFF14B8A6),
  ),
  ServiceCategory(
    label: 'Bridal Specialists',
    keyword: 'bridal',
    imageUrl: 'https://images.pexels.com/photos/2301842/pexels-photo-2301842.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.diamond_rounded,
    accent: Color(0xFFBE185D),
  ),
  ServiceCategory(
    label: 'Kids Hair Specialists',
    keyword: 'kids hair',
    imageUrl: 'https://images.pexels.com/photos/36489625/pexels-photo-36489625.jpeg?auto=compress&cs=tinysrgb&w=800',
    icon: Icons.child_care_rounded,
    accent: Color(0xFF059669),
  ),
];

/// Maps a professional's `category` (the name of their first attached
/// service — e.g. "Haircut", "Braiding" — set by the backend's fixed
/// service catalog) to the matching home-screen tile, so profile hero
/// banners can fall back to on-theme photography instead of a flat
/// gradient + initial when the professional hasn't uploaded their own
/// cover photo.
const Map<String, String> _serviceToCategoryLabel = {
  'haircut': 'Hair Styling',
  'braiding': 'Braiding Specialists',
  'manicure': 'Nail Technicians',
  'pedicure': 'Nail Technicians',
  'facial': 'Beauty Therapists',
  'makeup': 'Makeup Artists',
  'massage': 'Massage Therapists',
};

ServiceCategory? heroCategoryFor(String professionalCategory) {
  final label = _serviceToCategoryLabel[professionalCategory.trim().toLowerCase()];
  if (label == null) return null;
  for (final c in kServiceCategories) {
    if (c.label == label) return c;
  }
  return null;
}
