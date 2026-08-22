import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/data_provider.dart';
import '../widgets/ui.dart';
import 'my_requests_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<DataProvider>().fetchNotifications();
    });
  }

  IconData _iconFor(String type) {
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

  Color _colorFor(String type) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<DataProvider>().markAllNotificationsRead(),
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, _) {
          if (data.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              subtitle: 'Updates about your bookings and requests will show up here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => data.fetchNotifications(),
            child: ListView.separated(
              itemCount: data.notifications.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 72),
              itemBuilder: (context, i) {
                final n = data.notifications[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _colorFor(n.type).withOpacity(n.isRead ? 0.1 : 0.15),
                    child: Icon(_iconFor(n.type),
                        color: _colorFor(n.type), size: 20),
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
                              color: kSecondary, shape: BoxShape.circle),
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
          );
        },
      ),
    );
  }
}
