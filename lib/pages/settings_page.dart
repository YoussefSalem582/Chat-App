import 'package:chat_app/pages/notification_settings_page.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with simple design
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor:
                isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Settings',
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
                      Icons.settings_rounded,
                      size: 40,
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Appearance Section
                  _buildSectionHeader('Appearance', Icons.palette, isDark),
                  const SizedBox(height: 12),

                  // Dark mode toggle card
                  _buildDarkModeCard(isDark),

                  const SizedBox(height: 30),

                  // Notifications Section
                  _buildSectionHeader(
                    'Notifications',
                    Icons.notifications,
                    isDark,
                  ),
                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.notifications_active,
                    iconColor: Colors.orange,
                    title: 'Notification Settings',
                    subtitle: 'Manage push notifications',
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const NotificationSettingsPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Privacy & Security Section
                  _buildSectionHeader(
                    'Privacy & Security',
                    Icons.security,
                    isDark,
                  ),
                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.lock_outline,
                    iconColor: Colors.red,
                    title: 'Privacy',
                    subtitle: 'Control your privacy settings',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy settings coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.verified_user_outlined,
                    iconColor: Colors.green,
                    title: 'Security',
                    subtitle: 'Password and authentication',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Security settings coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.block,
                    iconColor: Colors.grey,
                    title: 'Blocked Users',
                    subtitle: 'Manage blocked contacts',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Blocked users coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Chat Settings Section
                  _buildSectionHeader('Chat', Icons.chat_bubble, isDark),
                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.wallpaper,
                    iconColor: Colors.purple,
                    title: 'Chat Wallpaper',
                    subtitle: 'Customize your chat background',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat wallpaper coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.backup,
                    iconColor: Colors.cyan,
                    title: 'Backup',
                    subtitle: 'Backup and restore chats',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Backup settings coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // About Section
                  _buildSectionHeader('About', Icons.info, isDark),
                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.help_outline,
                    iconColor: Colors.blue,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact us',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Help & Support coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.policy_outlined,
                    iconColor: Colors.indigo,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy policy coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSettingCard(
                    icon: Icons.article_outlined,
                    iconColor: Colors.teal,
                    title: 'Terms of Service',
                    subtitle: 'View terms and conditions',
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of service coming soon!'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // App version
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat,
                            color:
                                isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Chat App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 3.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Made with ❤️ in Flutter',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkModeCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDark ? 'Dark theme enabled' : 'Light theme enabled',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.85,
              child: CupertinoSwitch(
                value:
                    Provider.of<ThemeProvider>(
                      context,
                      listen: true,
                    ).isDarkMode,
                onChanged: (value) {
                  Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme();

                  // Haptic feedback
                  HapticFeedback.mediumImpact();
                },
                activeColor:
                    isDark ? Colors.grey.shade600 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
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
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
