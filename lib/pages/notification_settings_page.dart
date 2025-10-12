import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/notification/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _notificationService.loadSettings();
    setState(() {
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _soundEnabled = _notificationService.soundEnabled;
      _vibrationEnabled = _notificationService.vibrationEnabled;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting({
    bool? enabled,
    bool? sound,
    bool? vibration,
  }) async {
    await _notificationService.updateSettings(
      enabled: enabled,
      sound: sound,
      vibration: vibration,
    );

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings updated'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Notification Settings"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_active,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Stay connected with real-time notifications",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Enable Notifications
                  _buildSettingTile(
                    title: "Enable Notifications",
                    subtitle: "Receive notifications for new messages",
                    icon: Icons.notifications,
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      _updateSetting(enabled: value);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Sound
                  _buildSettingTile(
                    title: "Sound",
                    subtitle: "Play sound for notifications",
                    icon: Icons.volume_up,
                    value: _soundEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                      _updateSetting(sound: value);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Vibration
                  _buildSettingTile(
                    title: "Vibration",
                    subtitle: "Vibrate on new notifications",
                    icon: Icons.vibration,
                    value: _vibrationEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                      _updateSetting(vibration: value);
                    },
                  ),

                  const SizedBox(height: 32),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "About Notifications",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "• Get instant notifications when you receive new messages\n"
                          "• Notifications work even when the app is closed\n"
                          "• Customize sound and vibration preferences\n"
                          "• Your privacy is protected - only message alerts are sent",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color:
                enabled
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color:
                enabled ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
        trailing: CupertinoSwitch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }
}
