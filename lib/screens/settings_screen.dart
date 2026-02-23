import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

/// Settings: notifications, test notification, reminders, about.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _keyNotificationsEnabled = 'settings_notifications_enabled';
  static const _keyReminderHours = 'settings_reminder_hours';

  bool _notificationsEnabled = true;
  int _reminderHours = 24;
  bool _testSending = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
      _reminderHours = prefs.getInt(_keyReminderHours) ?? 24;
    });
  }

  Future<void> _saveNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveReminderHours(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderHours, value);
    setState(() => _reminderHours = value);
  }

  Future<void> _requestNotificationPermission() async {
    await Permission.notification.request();
  }

  Future<void> _sendTestNotification() async {
    setState(() => _testSending = true);
    try {
      await NotificationService().initialize();
      await _requestNotificationPermission();
      await NotificationService().showTestNotification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your status bar.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _testSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF9C27B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionTitle(title: 'Notifications'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Event reminders'),
                  subtitle: const Text('Get notified before events you book or save'),
                  value: _notificationsEnabled,
                  onChanged: _saveNotificationsEnabled,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Send test notification'),
                  subtitle: const Text('Trigger a notification now to check it works'),
                  trailing: _testSending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : FilledButton(
                          onPressed: _sendTestNotification,
                          child: const Text('Send'),
                        ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Remind me before event'),
                  subtitle: Text('$_reminderHours hours before'),
                  trailing: DropdownButton<int>(
                    value: _reminderHours,
                    items: [1, 6, 12, 24, 48, 168].map((h) {
                      final label = h < 24 ? '${h}h' : '${h ~/ 24} day${h > 24 ? 's' : ''}';
                      return DropdownMenuItem(value: h, child: Text(label));
                    }).toList(),
                    onChanged: (v) => v != null ? _saveReminderHours(v) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'App'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.grey.shade600),
                  title: const Text('About ZedEvents'),
                  subtitle: const Text('Version 1.0.0 · Events, reels & tickets'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: Image.asset(
                        'assets/images/app_icon.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 56),
                      ),
                      applicationName: 'ZedEvents',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'Discover events, watch reels, buy tickets. Built for Zambia.',
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.currency_exchange, color: Colors.grey.shade600),
                  title: const Text('Currency'),
                  subtitle: const Text('Zambian Kwacha (ZMW)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
