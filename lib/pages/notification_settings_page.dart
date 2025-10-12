import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/notification/notification_service.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();

  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _notificationService.loadSettings();
    setState(() {
      _notificationsEnabled = _notificationService.notificationsEnabled;
      _soundEnabled = _notificationService.soundEnabled;
      _vibrationEnabled = _notificationService.vibrationEnabled;
      _isLoading = false;
    });
    _animationController.forward();
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

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings updated'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor:
                isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Notifications',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Container(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 50,
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child:
                _isLoading
                    ? const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Header card
                            _buildHeaderCard(isDark),

                            const SizedBox(height: 30),

                            // Enable Notifications
                            _buildModernSettingTile(
                              title: "Enable Notifications",
                              subtitle:
                                  "Receive notifications for new messages",
                              icon: Icons.notifications_active,
                              iconColor: Colors.orange,
                              value: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _notificationsEnabled = value;
                                });
                                _updateSetting(enabled: value);
                              },
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            // Sound
                            _buildModernSettingTile(
                              title: "Sound",
                              subtitle: "Play sound for notifications",
                              icon: Icons.volume_up_rounded,
                              iconColor: Colors.blue,
                              value: _soundEnabled,
                              enabled: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _soundEnabled = value;
                                });
                                _updateSetting(sound: value);
                              },
                              isDark: isDark,
                            ),

                            const SizedBox(height: 12),

                            // Vibration
                            _buildModernSettingTile(
                              title: "Vibration",
                              subtitle: "Vibrate on new notifications",
                              icon: Icons.vibration,
                              iconColor: Colors.purple,
                              value: _vibrationEnabled,
                              enabled: _notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _vibrationEnabled = value;
                                });
                                _updateSetting(vibration: value);
                              },
                              isDark: isDark,
                            ),

                            const SizedBox(height: 30),

                            // Info section
                            _buildInfoCard(isDark),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 32,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            "Stay Connected",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Get instant notifications for messages",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    enabled
                        ? (isDark ? Colors.grey.shade700 : Colors.grey.shade100)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color:
                    enabled
                        ? (isDark ? Colors.grey.shade400 : Colors.grey.shade700)
                        : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          enabled
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          enabled
                              ? (isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600)
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeColor:
                    isDark ? Colors.grey.shade600 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "About Notifications",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.check_circle_outline,
            "Get instant alerts for new messages",
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.check_circle_outline,
            "Works even when app is closed",
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.check_circle_outline,
            "Customize sound and vibration",
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.check_circle_outline,
            "Your privacy is always protected",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
