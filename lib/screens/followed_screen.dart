import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../models/professional_post.dart';
import '../providers/data_provider.dart';
import '../widgets/ui.dart';
import 'professional_profile_screen.dart';

/// "Following" — followed professionals' activity feed, tabbed by type
/// (All / Offers / Updates / Styles). Mock-up screen 8.
class FollowedScreen extends StatefulWidget {
  const FollowedScreen({super.key});

  @override
  State<FollowedScreen> createState() => _FollowedScreenState();
}

class _FollowedScreenState extends State<FollowedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  static const _types = [null, 'offer', 'update', 'style'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) _load();
    });
    Future.microtask(_load);
  }

  void _load() {
    context
        .read<DataProvider>()
        .fetchFollowedFeed(type: _types[_tab.index]);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          labelColor: kPrimary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: kSecondary,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Offers'),
            Tab(text: 'Updates'),
            Tab(text: 'Styles'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.followLoading && data.followedFeed.isEmpty) {
            return const AppSkeletonList(itemHeight: 84);
          }
          if (data.followedFeed.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'Nothing here yet',
              subtitle:
                  'Follow your favourite professionals to see their latest styles, updates and offers here.',
              actionLabel: 'Refresh',
              onAction: _load,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.followedFeed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _FeedCard(post: data.followedFeed[i]),
            ),
          );
        },
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final ProfessionalPost post;
  const _FeedCard({required this.post});

  ({Color color, String label, IconData icon}) get _typeMeta {
    switch (post.type) {
      case 'offer':
        return (color: kSecondary, label: 'Offer', icon: Icons.local_offer_rounded);
      case 'style':
        return (color: const Color(0xFFEC4899), label: 'Style', icon: Icons.auto_awesome_rounded);
      default:
        return (color: const Color(0xFF3B82F6), label: 'Update', icon: Icons.campaign_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = _typeMeta;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ProfessionalProfileScreen(id: post.professionalId),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: kPrimarySoft,
                backgroundImage: post.professionalPhoto != null
                    ? CachedNetworkImageProvider(post.professionalPhoto!)
                    : null,
                child: post.professionalPhoto == null
                    ? Text(
                        (post.professionalName.isNotEmpty
                                ? post.professionalName[0]
                                : 'P')
                            .toUpperCase(),
                        style: const TextStyle(
                            color: kPrimary, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(post.professionalName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        _TypeChip(meta: meta),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(post.title,
                        style: TextStyle(
                            color: Colors.grey.shade800, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(_timeAgo(post.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ),
              if (post.imageUrl != null) ...[
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final ({Color color, String label, IconData icon}) meta;
  const _TypeChip({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: meta.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 11, color: meta.color),
          const SizedBox(width: 3),
          Text(meta.label,
              style: TextStyle(
                  color: meta.color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

String _timeAgo(String? iso) {
  if (iso == null) return '';
  final dt = DateTime.tryParse(iso);
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
