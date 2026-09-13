import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../data/service_categories.dart';
import '../models/portfolio_photo.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../providers/data_provider.dart';
import 'booking_screen.dart';
import 'following_confirmation_screen.dart';

class ProfessionalProfileScreen extends StatefulWidget {
  final int id;
  const ProfessionalProfileScreen({super.key, required this.id});

  @override
  State<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState extends State<ProfessionalProfileScreen> {
  Professional? _professional;
  List<Review> _reviews = [];
  List<PortfolioPhoto> _portfolio = [];
  bool _isLoading = true;

  bool _isFollowing = false;
  int _followersCount = 0;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final provider = context.read<DataProvider>();
    final pro = await provider.fetchProfessionalDetail(widget.id);
    List<Review> reviews = [];
    List<PortfolioPhoto> portfolio = [];
    if (pro != null) {
      final results = await Future.wait([
        provider.fetchProfessionalReviews(pro.id),
        provider.fetchProfessionalPortfolio(pro.id),
      ]);
      reviews = results[0] as List<Review>;
      portfolio = results[1] as List<PortfolioPhoto>;
    }
    if (mounted) {
      setState(() {
        _professional = pro;
        _reviews = reviews;
        _portfolio = portfolio;
        _isFollowing = pro?.isFollowing ?? false;
        _followersCount = pro?.followersCount ?? 0;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final pro = _professional;
    if (pro == null || _followBusy) return;
    setState(() => _followBusy = true);
    final provider = context.read<DataProvider>();
    final wasFollowing = _isFollowing;

    final ok = wasFollowing
        ? await provider.unfollowProfessional(pro.id)
        : await provider.followProfessional(pro.id);

    if (!mounted) return;
    setState(() {
      _followBusy = false;
      if (ok) {
        _isFollowing = !wasFollowing;
        _followersCount += _isFollowing ? 1 : -1;
      }
    });

    if (ok && !wasFollowing) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FollowingConfirmationScreen(professional: pro),
        ),
      );
    }
  }

  void _openBookingSheet() {
    final pro = _professional!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('How would you like the service?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: kPrimarySoft,
                child: Icon(Icons.store_mall_directory_rounded, color: kPrimary),
              ),
              title: const Text('Book — At the salon'),
              subtitle: const Text('You go to the professional'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      BookingScreen(professional: pro, type: 'booking'),
                ));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: kSecondarySoft,
                child: Icon(Icons.near_me_rounded, color: kSecondary),
              ),
              title: const Text('Request — Home service'),
              subtitle: const Text('The professional comes to you'),
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      BookingScreen(professional: pro, type: 'request'),
                ));
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_professional == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Professional not found')),
      );
    }
    final pro = _professional!;
    final services = pro.services ?? [];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero image ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: kPlumDark,
            foregroundColor: Colors.white,
            systemOverlayStyle: null,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: _toggleFollow,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  pro.profilePhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: pro.profilePhotoUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _heroFallback(pro),
                        )
                      : _heroFallback(pro),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x66000000), Color(0xEE1A0F19)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Identity row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: kPrimarySoft,
                        backgroundImage: pro.profilePhotoUrl != null
                            ? CachedNetworkImageProvider(pro.profilePhotoUrl!)
                            : null,
                        child: pro.profilePhotoUrl == null
                            ? Text(
                                (pro.name.isNotEmpty ? pro.name[0] : 'P')
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pro.name,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kTextDark)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 3),
                                Text(
                                  '${pro.averageRating.toStringAsFixed(1)} (${pro.reviewsCount} reviews)',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (pro.isVerified) ...[
                        const Icon(Icons.verified_rounded,
                            color: Color(0xFF3B82F6), size: 18),
                        const SizedBox(width: 4),
                        const Text('Verified Professional',
                            style: TextStyle(
                                color: Color(0xFF3B82F6),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        const SizedBox(width: 12),
                      ],
                      Icon(Icons.people_alt_rounded,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('$_followersCount followers',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(pro.location,
                              style: TextStyle(color: Colors.grey.shade700))),
                    ],
                  ),

                  // Portfolio
                  if (_portfolio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Portfolio',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${_portfolio.length} photo${_portfolio.length == 1 ? '' : 's'}',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _PortfolioStrip(photos: _portfolio),
                  ],

                  // About
                  if (pro.bio.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('About',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(pro.bio,
                        style: TextStyle(
                            color: Colors.grey.shade700, height: 1.4)),
                    if (pro.yearsExperience != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              size: 16, color: kSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${pro.yearsExperience} year${pro.yearsExperience! == 1 ? '' : 's'} of experience',
                            style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],

                  // Working Hours
                  if (pro.workingHours != null && pro.workingHours!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text('Working Hours',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...pro.workingHours!.map((wh) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              wh.dayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                          Text(
                            wh.hoursLabel,
                            style: TextStyle(
                              color: wh.isClosed
                                  ? Colors.red.shade400
                                  : Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Services & Prices
                  const SizedBox(height: 20),
                  const Text('Services & Prices',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (services.isEmpty)
                    Text('No services listed yet.',
                        style: TextStyle(color: Colors.grey.shade600))
                  else
                    ...services.take(6).map(
                          (s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(s.name,
                                        style: const TextStyle(fontSize: 14))),
                                Text(
                                  'TZS ${s.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: kTextDark),
                                ),
                              ],
                            ),
                          ),
                        ),

                  // Reviews
                  if (_reviews.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text('Reviews (${_reviews.length})',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._reviews.take(3).map(
                          (r) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.reviewerName ?? 'Anonymous',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < r.rating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  if (r.comment != null &&
                                      r.comment!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(r.comment!),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        isFollowing: _isFollowing,
        followBusy: _followBusy,
        onRequest: _openBookingSheet,
        onFollow: _toggleFollow,
      ),
    );
  }

  Widget _heroFallback(Professional pro) {
    final category = heroCategoryFor(pro.category);
    if (category != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: category.imageUrl,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _heroGradient(pro),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x991A0F19)],
                stops: [0.5, 1.0],
              ),
            ),
          ),
        ],
      );
    }
    return _heroGradient(pro);
  }

  Widget _heroGradient(Professional pro) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kPrimary, kPlumDark],
          ),
        ),
        child: Center(
          child: Text(
            (pro.name.isNotEmpty ? pro.name[0] : 'P').toUpperCase(),
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 80,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
}

// ─── Portfolio strip ─────────────────────────────────────────────────────────

class _PortfolioStrip extends StatelessWidget {
  final List<PortfolioPhoto> photos;
  const _PortfolioStrip({required this.photos});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final photo = photos[i];
          return GestureDetector(
            onTap: () => _showFullscreen(context, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: photo.photoUrl,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                    width: 96, height: 96, color: const Color(0xFFECE6DF)),
                errorWidget: (_, __, ___) => Container(
                  width: 96,
                  height: 96,
                  color: kPrimarySoft,
                  child: const Icon(Icons.image_outlined, color: kPrimary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFullscreen(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: photos.length,
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: photos[i].photoUrl,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 32,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom action bar ──────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isFollowing;
  final bool followBusy;
  final VoidCallback onRequest;
  final VoidCallback onFollow;

  const _BottomBar({
    required this.isFollowing,
    required this.followBusy,
    required this.onRequest,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: kBackground,
          border: Border(top: BorderSide(color: Color(0xFFEDE6DF))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onRequest,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary),
                ),
                child: const Text('Request / Book'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: followBusy ? null : onFollow,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  backgroundColor: isFollowing ? Colors.white : kSecondary,
                  foregroundColor: isFollowing ? kTextDark : kPlumDark,
                  side: isFollowing
                      ? const BorderSide(color: Color(0xFFDDD3CA))
                      : null,
                  elevation: 0,
                ),
                icon: Icon(
                  isFollowing
                      ? Icons.check_rounded
                      : Icons.add_rounded,
                  size: 18,
                ),
                label: Text(isFollowing ? 'Following' : 'Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
