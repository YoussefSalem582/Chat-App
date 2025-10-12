import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:chat_app/components/components.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import '../services/profile/profile_service.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileService _profileService = ProfileService();

  // search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // User data
  String? _currentUserEmoji;
  Uint8List? _currentUserImageBytes;
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUserOnline();
    _loadCurrentUserData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadCurrentUserData() async {
    final userId = _authService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        // Load user profile data
        final userDoc = await _firestore.collection("Users").doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final emoji = data?['emojiAvatar'] as String?;
          final hasProfileImage = data?['hasProfileImage'] as bool? ?? false;

          setState(() {
            _currentUserEmoji = emoji;
          });

          // Load profile image if available
          if (hasProfileImage) {
            try {
              final bytes = await _profileService.getUserProfileImage(userId);
              if (mounted) {
                setState(() {
                  _currentUserImageBytes = bytes;
                });
              }
            } catch (e) {
              // Image loading failed, no problem
            }
          }
        }
      } catch (e) {
        // Handle error silently
      } finally {
        if (mounted) {
          setState(() {
            _isLoadingUserData = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _setUserOnline();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _setUserOffline();
    }
  }

  Future<void> _setUserOnline() async {
    final userId = _authService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        await _firestore.collection("Users").doc(userId).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Handle error silently
      }
    }
  }

  Future<void> _setUserOffline() async {
    final userId = _authService.getCurrentUser()?.uid;
    if (userId != null) {
      try {
        await _firestore.collection("Users").doc(userId).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Handle error silently
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with simple design
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor:
                isDark ? Colors.grey.shade900 : Colors.grey.shade50,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Row(
                            children: [
                              // User Avatar with emoji support
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child:
                                      _isLoadingUserData
                                          ? Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color:
                                                  isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                            ),
                                          )
                                          : _currentUserImageBytes != null
                                          ? Image.memory(
                                            _currentUserImageBytes!,
                                            fit: BoxFit.cover,
                                          )
                                          : _currentUserEmoji != null &&
                                              _currentUserEmoji!.isNotEmpty
                                          ? Center(
                                            child: Text(
                                              _currentUserEmoji!,
                                              style: const TextStyle(
                                                fontSize: 28,
                                              ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.person,
                                            color:
                                                isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                            size: 26,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Welcome text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _authService
                                              .getCurrentUser()
                                              ?.email
                                              ?.split('@')[0] ??
                                          'User',
                                      style: TextStyle(
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.grey.shade900,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Notification Icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? Colors.grey.shade800
                                          : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color:
                                      isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade700,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.grey.shade900,
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey.shade700 : Colors.grey.shade200,
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
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search conversations...',
                      hintStyle: TextStyle(
                        color:
                            isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color:
                                      isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Recent Chats',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey.shade900,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: StreamBuilder(
                      stream: _chatService.getUserStream(),
                      builder: (context, snapshot) {
                        int count = 0;
                        if (snapshot.hasData) {
                          count =
                              snapshot.data!
                                  .where(
                                    (user) =>
                                        user["email"] !=
                                        _authService.getCurrentUser()?.email,
                                  )
                                  .length;
                        }
                        return Text(
                          '$count users',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // User list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _buildUserList(),
          ),
        ],
      ),
    );
  }

  // build a list of users except for the current user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading users",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${snapshot.error}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    "Loading conversations...",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Filter and build user list
        final filteredUsers =
            snapshot.data!
                .where((userData) {
                  // Filter by search query
                  if (_searchQuery.isEmpty) return true;
                  // Handle null email safely
                  String? email = userData["email"];
                  if (email == null) return false;
                  return email.toLowerCase().contains(_searchQuery);
                })
                .where((userData) {
                  // Exclude current user
                  String? email = userData["email"];
                  return email != _authService.getCurrentUser()?.email;
                })
                .toList();

        if (filteredUsers.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty ? "No users yet" : "No users found",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isEmpty
                        ? "Users will appear here when they sign up"
                        : "Try a different search term",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // return animated list
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _buildUserListTile(filteredUsers[index], context),
            );
          }, childCount: filteredUsers.length),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListTile(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // Handle null values safely
    String? email = userData["email"];
    String? uid = userData["uid"];
    String? displayName = userData["displayName"];
    String? phoneNumber = userData["phoneNumber"];
    // Get online status from userData, default to false
    bool isOnline = userData["isOnline"] ?? false;

    // Skip if essential data is missing
    if (email == null && phoneNumber == null && displayName == null) {
      return Container();
    }

    // Create display text (prefer email, fallback to displayName or phone)
    String displayText = email ?? displayName ?? phoneNumber ?? "Unknown User";
    String? photoURL = userData["photoURL"];
    String? emojiAvatar = userData["emojiAvatar"];
    bool? hasProfileImage = userData["hasProfileImage"];

    return ModernUserTile(
      email: displayText,
      userId: uid ?? "",
      displayName: displayName,
      photoURL: photoURL,
      emojiAvatar: emojiAvatar,
      hasProfileImage: hasProfileImage,
      isOnline: isOnline,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ChatPage(
                  receiverEmail: email ?? displayText,
                  receiverID: uid ?? "",
                ),
          ),
        );
      },
    );
  }
}
