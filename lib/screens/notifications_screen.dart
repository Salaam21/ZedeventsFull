import 'package:flutter/material.dart';
import 'package:event_app/data/notification_model.dart';
import 'package:event_app/services/notifications_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationsRepository _repo = NotificationsRepository();
  List<NotificationModel> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _repo.fetch();
    if (!mounted) return;
    setState(() {
      _list = list;
      _loading = false;
    });
  }

  Future<void> _markRead(NotificationModel n) async {
    await _repo.markAsRead(n.id);
    setState(() {
      final i = _list.indexWhere((e) => e.id == n.id);
      if (i >= 0) _list[i] = _list[i].copyWith(read: true);
    });
  }

  Future<void> _markAllRead() async {
    await _repo.markAllRead();
    setState(() {
      _list = _list.map((n) => n.copyWith(read: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_repo.unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? const Center(child: Text('No notifications'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (context, i) {
                      final n = _list[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.read ? Colors.grey.shade300 : Colors.blue.shade100,
                          child: Icon(n.eventId != null ? Icons.event : Icons.video_library, color: n.read ? Colors.grey : Colors.blue),
                        ),
                        title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.normal : FontWeight.w600)),
                        subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        isThreeLine: true,
                        onTap: () => _markRead(n),
                      );
                    },
                  ),
                ),
    );
  }
}
