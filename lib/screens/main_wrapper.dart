import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import 'conversations_screen.dart';
import 'edit_customer_profile_screen.dart';
import 'followed_screen.dart';
import 'home_screen.dart';
import 'my_bookings_screen.dart';
import 'my_requests_screen.dart';
import 'notifications_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MyBookingsScreen(),
    FollowedScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DataProvider>().fetchUnreadCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Consumer<DataProvider>(
        builder: (context, data, _) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: cs.primary,
            unselectedItemColor: const Color(0xFFB0B5C4),
            elevation: 0,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 3) {
                data.fetchConversations();
                data.fetchNotifications();
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Bookings',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Following',
              ),
              BottomNavigationBarItem(
                icon: _InboxIcon(unread: data.totalUnread),
                activeIcon: _InboxIcon(unread: data.totalUnread, active: true),
                label: 'Inbox',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxIcon extends StatelessWidget {
  final int unread;
  final bool active;
  const _InboxIcon({required this.unread, this.active = false});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(active ? Icons.inbox_rounded : Icons.inbox_outlined);
    if (unread == 0) return icon;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        icon,
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
            child: Text(
              unread > 9 ? '9+' : '$unread',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Profile Screen ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingPhoto = false;

  Future<void> _pickPhoto(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null || !mounted) return;

    final sm = ScaffoldMessenger.of(context);
    final dataProvider = context.read<DataProvider>();
    final authProvider = context.read<AuthProvider>();

    setState(() => _uploadingPhoto = true);
    final ok = await dataProvider.uploadProfilePhoto(file.path);
    if (ok) await authProvider.refreshUser();
    if (mounted) {
      setState(() => _uploadingPhoto = false);
      sm.showSnackBar(
        SnackBar(
          content: Text(ok ? 'Photo updated!' : 'Failed to upload photo. Please try again.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: ok ? null : Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit profile',
                onPressed: user == null
                    ? null
                    : () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditCustomerProfileScreen(user: user),
                          ),
                        );
                      },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary,
                      Color.lerp(cs.primary, const Color(0xFF2D3A8C), 0.45)!,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => _pickPhoto(context),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: user?.profilePhotoUrl != null
                                  ? CachedNetworkImageProvider(user!.profilePhotoUrl!)
                                  : null,
                              child: user?.profilePhotoUrl == null
                                  ? Text(
                                      (user?.name ?? 'U')[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: cs.primary, width: 1.5),
                                ),
                                child: _uploadingPhoto
                                    ? Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: cs.primary,
                                        ),
                                      )
                                    : Icon(Icons.camera_alt_rounded,
                                        size: 14, color: cs.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user?.name ?? 'User',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Contact info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          if (user?.email != null && user!.email!.isNotEmpty)
                            _InfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email!,
                            ),
                          if (user?.phone != null && user!.phone!.isNotEmpty)
                            _InfoTile(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: user.phone!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Account section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          _ActionTile(
                            icon: Icons.broadcast_on_personal_outlined,
                            label: 'My Requests',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const MyRequestsScreen()),
                            ),
                          ),
                          _ActionTile(
                            icon: Icons.notifications_outlined,
                            label: 'Notifications',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const NotificationsScreen()),
                            ),
                          ),
                          _ActionTile(
                            icon: Icons.help_outline_rounded,
                            label: 'Help & Support',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        foregroundColor: Colors.red,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
      title: Text(label,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle:
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      dense: true,
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Icon(Icons.chevron_right,
          color: Colors.grey.shade300, size: 20),
      dense: true,
      onTap: onTap,
    );
  }
}
