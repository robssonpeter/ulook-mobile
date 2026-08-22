import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/data_provider.dart';
import '../widgets/ui.dart';
import 'chat_screen.dart';
import 'my_requests_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      if (mounted) {
        context.read<DataProvider>().fetchConversations();
        context.read<DataProvider>().fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Consumer<DataProvider>(
              builder: (_, data, __) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Messages'),
                    if (data.unreadMessages > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(count: data.unreadMessages),
                    ],
                  ],
                ),
              ),
            ),
            Consumer<DataProvider>(
              builder: (_, data, __) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Alerts'),
                    if (data.unreadNotifications > 0) ...[
                      const SizedBox(width: 6),
                      _Badge(count: data.unreadNotifications),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MessagesTab(),
          _NotificationsTab(),
        ],
      ),
    );
  }
}

// ─── Messages tab ─────────────────────────────────────────────────────────────

class _MessagesTab extends StatelessWidget {
  const _MessagesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        if (data.conversations.isEmpty) {
          return const EmptyState(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            subtitle: 'Chat with a professional from your bookings and messages will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => data.fetchConversations(),
          child: ListView.separated(
            itemCount: data.conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, i) {
              final c = data.conversations[i];
              return ListTile(
                leading: c.otherUserPhotoUrl != null
                    ? CircleAvatar(
                        backgroundImage:
                            CachedNetworkImageProvider(c.otherUserPhotoUrl!))
                    : CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        child: Text(
                          c.otherUserName[0].toUpperCase(),
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                title: Text(c.otherUserName,
                    style: TextStyle(
                        fontWeight: c.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal)),
                subtitle: Text(c.lastMessage,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: c.unreadCount > 0
                    ? _Badge(count: c.unreadCount)
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      otherUserId: c.otherUserId,
                      otherUserName: c.otherUserName,
                      otherUserPhotoUrl: c.otherUserPhotoUrl,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Notifications tab ────────────────────────────────────────────────────────

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab();

  IconData _icon(String type) {
    switch (type) {
      case 'new_response':
        return Icons.price_check;
      case 'response_accepted':
        return Icons.check_circle;
      case 'new_message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _color(String type) {
    switch (type) {
      case 'new_response':
        return Colors.orange;
      case 'response_accepted':
        return Colors.green;
      case 'new_message':
        return Colors.blue;
      default:
        return kPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, _) {
        if (data.notifications.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            subtitle: 'Updates about your bookings and requests will show up here.',
          );
        }
        return Column(
          children: [
            if (data.unreadNotifications > 0)
              TextButton.icon(
                onPressed: () => data.markAllNotificationsRead(),
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('Mark all as read'),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => data.fetchNotifications(),
                child: ListView.separated(
                  itemCount: data.notifications.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) {
                    final n = data.notifications[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _color(n.type)
                            .withOpacity(n.isRead ? 0.08 : 0.15),
                        child: Icon(_icon(n.type),
                            color: _color(n.type), size: 20),
                      ),
                      title: Text(n.title,
                          style: TextStyle(
                              fontWeight: n.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold)),
                      subtitle: Text(n.body),
                      trailing: n.isRead
                          ? null
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: kSecondary,
                                  shape: BoxShape.circle),
                            ),
                      onTap: () {
                        if (!n.isRead) data.markNotificationRead(n.id);
                        if (n.type == 'new_response' || n.type == 'response_accepted') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MyRequestsScreen()),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style:
            const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
