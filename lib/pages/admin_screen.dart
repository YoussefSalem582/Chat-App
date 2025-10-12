import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/admin/admin_stat_card.dart';
import '../components/admin/admin_tab_button.dart';
import '../components/admin/user_list_item.dart';
import '../components/admin/analytics_card.dart';
import 'onboarding_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  // Analytics data
  int totalUsers = 0;
  int onlineUsers = 0;
  int totalMessages = 0;
  int totalChats = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);

    try {
      print('🔄 Loading analytics...');

      // Get total users
      final usersSnapshot = await _firestore.collection('Users').get();
      totalUsers = usersSnapshot.docs.length;
      print('👥 Total users: $totalUsers');

      // Get online users
      onlineUsers =
          usersSnapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            return data?['isOnline'] == true;
          }).length;
      print('🟢 Online users: $onlineUsers');

      // Get total chats
      final chatsSnapshot = await _firestore.collection('chats').get();
      totalChats = chatsSnapshot.docs.length;
      print('💬 Total chats: $totalChats');

      // Get total messages (count all messages in all chats)
      int messageCount = 0;
      if (chatsSnapshot.docs.isNotEmpty) {
        for (var chat in chatsSnapshot.docs) {
          try {
            final messagesSnapshot =
                await _firestore
                    .collection('chats')
                    .doc(chat.id)
                    .collection('messages')
                    .get();
            messageCount += messagesSnapshot.docs.length;
            print(
              '  Chat ${chat.id}: ${messagesSnapshot.docs.length} messages',
            );
          } catch (e) {
            print('  Error loading messages for chat ${chat.id}: $e');
          }
        }
      }
      totalMessages = messageCount;
      print('📨 Total messages: $totalMessages');

      print('✅ Analytics loaded successfully');
      setState(() => isLoading = false);
    } catch (e) {
      print('❌ Error loading analytics: $e');
      setState(() => isLoading = false);

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadAnalytics,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: () async {
              // Show confirmation dialog
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
              );

              if (shouldLogout == true && context.mounted) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  // Navigate to onboarding and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Analytics Cards at top (only in Analytics tab)
          if (_selectedIndex == 0)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF667eea),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    if (isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AdminStatCard(
                                  title: 'Total Users',
                                  value: totalUsers.toString(),
                                  icon: Icons.people,
                                  iconColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdminStatCard(
                                  title: 'Online Now',
                                  value: onlineUsers.toString(),
                                  icon: Icons.circle,
                                  iconColor: Colors.greenAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: AdminStatCard(
                                  title: 'Total Chats',
                                  value: totalChats.toString(),
                                  icon: Icons.chat_bubble,
                                  iconColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdminStatCard(
                                  title: 'Messages',
                                  value: totalMessages.toString(),
                                  icon: Icons.message,
                                  iconColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

          // Navigation Tabs
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AdminTabButton(
                      title: 'Analytics',
                      icon: Icons.analytics_outlined,
                      index: 0,
                      selectedIndex: _selectedIndex,
                      isDarkMode: isDarkMode,
                      onTap: () => setState(() => _selectedIndex = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AdminTabButton(
                      title: 'Users',
                      icon: Icons.people_outline,
                      index: 1,
                      selectedIndex: _selectedIndex,
                      isDarkMode: isDarkMode,
                      onTap: () => setState(() => _selectedIndex = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          _selectedIndex == 0
              ? _buildAnalyticsView(isDarkMode)
              : _buildUsersView(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView(bool isDarkMode) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            'Real-Time Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          AnalyticsCard(
            title: 'User Activity',
            isDarkMode: isDarkMode,
            children: [
              AnalyticsRow(
                label: 'Total Registered Users',
                value: totalUsers.toString(),
              ),
              AnalyticsRow(
                label: 'Currently Online',
                value: onlineUsers.toString(),
              ),
              AnalyticsRow(
                label: 'Offline Users',
                value: (totalUsers - onlineUsers).toString(),
              ),
              AnalyticsRow(
                label: 'Activity Rate',
                value:
                    totalUsers > 0
                        ? '${((onlineUsers / totalUsers) * 100).toStringAsFixed(1)}%'
                        : '0%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnalyticsCard(
            title: 'Communication Stats',
            isDarkMode: isDarkMode,
            children: [
              AnalyticsRow(
                label: 'Total Conversations',
                value: totalChats.toString(),
              ),
              AnalyticsRow(
                label: 'Total Messages Sent',
                value: totalMessages.toString(),
              ),
              AnalyticsRow(
                label: 'Avg Messages per Chat',
                value:
                    totalChats > 0
                        ? (totalMessages / totalChats).toStringAsFixed(1)
                        : '0',
              ),
              AnalyticsRow(
                label: 'Avg Messages per User',
                value:
                    totalUsers > 0
                        ? (totalMessages / totalUsers).toStringAsFixed(1)
                        : '0',
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnalyticsCard(
            title: 'Platform Overview',
            isDarkMode: isDarkMode,
            children: [
              AnalyticsRow(label: 'Active Chats', value: totalChats.toString()),
              const AnalyticsRow(
                label: 'Platform Status',
                value: 'Operational',
                valueColor: Colors.green,
              ),
              AnalyticsRow(
                label: 'Last Updated',
                value: TimeOfDay.now().format(context),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _buildUsersView(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        final users = snapshot.data!.docs;

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final docId = users[index].id;

              return UserListItem(
                userData: userData,
                isDarkMode: isDarkMode,
                onEdit: () => _editUser(context, docId, userData),
                onDelete: () => _deleteUser(context, docId, userData),
              );
            }, childCount: users.length),
          ),
        );
      },
    );
  }

  void _editUser(
    BuildContext context,
    String docId,
    Map<String, dynamic> userData,
  ) {
    final nameController = TextEditingController(
      text: userData['displayName'] ?? '',
    );
    final emailController = TextEditingController(
      text: userData['email'] ?? '',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit User'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    enabled: false, // Can't change email
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _firestore.collection('Users').doc(docId).update({
                      'displayName': nameController.text.trim(),
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteUser(
    BuildContext context,
    String docId,
    Map<String, dynamic> userData,
  ) {
    final displayName = userData['displayName'] ?? 'Unknown User';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete User'),
            content: Text(
              'Are you sure you want to delete "$displayName"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Delete user from Firestore
                    await _firestore.collection('Users').doc(docId).delete();

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User deleted successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      _loadAnalytics(); // Reload analytics
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
