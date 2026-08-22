import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../data/service_categories.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import 'category_listing_screen.dart';
import 'notifications_screen.dart';
import 'open_request_screen.dart';

/// Home = "What beauty service do you need?" — a grid of photo category
/// tiles, the first thing the customer sees on open (matches the mock-up).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName =
        (user?.name ?? '').trim().split(' ').firstWhere((s) => s.isNotEmpty,
            orElse: () => '');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isEmpty
                                ? 'What beauty service\ndo you need?'
                                : 'Hi $firstName 👋\nWhat do you need today?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explore top professionals near you',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Category grid ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _CategoryTile(category: kServiceCategories[i]),
                  childCount: kServiceCategories.length,
                ),
              ),
            ),

            // ── Request CTA banner ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: _RequestBanner(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const OpenRequestScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category tile ──────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category;
  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryListingScreen(category: category),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo (with graceful fallback to a coloured icon tile)
              CachedNetworkImage(
                imageUrl: category.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: const Color(0xFFECE6DF),
                  highlightColor: Colors.white,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => _FallbackTile(category: category),
              ),
              // Dark gradient so the label stays readable
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC1A0F19)],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Text(
                  category.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackTile extends StatelessWidget {
  final ServiceCategory category;
  const _FallbackTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [category.accent, category.accent.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Icon(category.icon, color: Colors.white.withOpacity(0.9), size: 44),
      ),
    );
  }
}

// ─── Request banner ─────────────────────────────────────────────────────────

class _RequestBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RequestBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kPrimary, kPlumDark],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: kSecondary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.near_me_rounded, color: kSecondary),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Want them to come to you?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Post a request and let pros nearby respond',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Small round icon button ────────────────────────────────────────────────

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(side: BorderSide(color: Color(0xFFEDE6DF))),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: kTextDark),
        ),
      ),
    );
  }
}
