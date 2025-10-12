import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/chat/chat_service.dart';
import '../../services/profile/profile_service.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String receiverEmail;
  final String receiverID;
  final bool isSearching;
  final bool isSelectionMode;
  final VoidCallback onSearchToggle;
  final VoidCallback onMoreOptions;
  final VoidCallback onDeleteSelected;
  final ChatService chatService;

  const ChatAppBar({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
    required this.isSearching,
    required this.isSelectionMode,
    required this.onSearchToggle,
    required this.onMoreOptions,
    required this.onDeleteSelected,
    required this.chatService,
  });

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _ChatAppBarState extends State<ChatAppBar> {
  final ProfileService _profileService = ProfileService();
  Uint8List? _receiverImageBytes;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadReceiverData();
  }

  Future<void> _loadReceiverData() async {
    // Load receiver's profile image if they have one
    final receiverData =
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(widget.receiverID)
            .get();

    if (receiverData.exists) {
      final data = receiverData.data();
      if (data?['hasProfileImage'] == true) {
        setState(() => _isLoadingImage = true);
        try {
          final bytes = await _profileService.getUserProfileImage(
            widget.receiverID,
          );
          if (mounted) {
            setState(() {
              _receiverImageBytes = bytes;
              _isLoadingImage = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoadingImage = false);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? Colors.white : Colors.grey.shade900,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: _buildTitle(context, isDark),
      actions: _buildActions(context, isDark),
    );
  }

  Widget _buildTitle(BuildContext context, bool isDark) {
    return StreamBuilder<DocumentSnapshot>(
      stream: widget.chatService.getUserStatus(widget.receiverID),
      builder: (context, snapshot) {
        bool isOnline = false;
        String lastSeen = '';
        String? emojiAvatar;
        String? displayName;

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          isOnline = data?['isOnline'] ?? false;
          emojiAvatar = data?['emojiAvatar'];
          displayName = data?['displayName'];

          if (!isOnline && data?['lastSeen'] != null) {
            final lastSeenTime = (data!['lastSeen'] as Timestamp).toDate();
            final now = DateTime.now();
            final difference = now.difference(lastSeenTime);

            if (difference.inMinutes < 1) {
              lastSeen = 'Just now';
            } else if (difference.inHours < 1) {
              lastSeen = '${difference.inMinutes}m ago';
            } else if (difference.inDays < 1) {
              lastSeen = '${difference.inHours}h ago';
            } else {
              lastSeen = '${difference.inDays}d ago';
            }
          }
        }

        final userName = displayName ?? widget.receiverEmail.split('@')[0];

        return Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child:
                    _isLoadingImage
                        ? Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade700,
                          ),
                        )
                        : _receiverImageBytes != null
                        ? Image.memory(_receiverImageBytes!, fit: BoxFit.cover)
                        : emojiAvatar != null && emojiAvatar.isNotEmpty
                        ? Center(
                          child: Text(
                            emojiAvatar,
                            style: const TextStyle(fontSize: 22),
                          ),
                        )
                        : Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                            ),
                          ),
                        ),
              ),
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName ?? widget.receiverEmail,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color:
                              isOnline
                                  ? Colors.green.shade500
                                  : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : lastSeen,
                        style: TextStyle(
                          color:
                              isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isDark) {
    final iconColor = isDark ? Colors.white : Colors.grey.shade900;

    if (widget.isSelectionMode) {
      return [
        IconButton(
          icon: Icon(Icons.delete, color: iconColor),
          onPressed: widget.onDeleteSelected,
        ),
      ];
    }

    return [
      IconButton(
        icon: Icon(
          widget.isSearching ? Icons.close : Icons.search,
          color: iconColor,
        ),
        onPressed: widget.onSearchToggle,
      ),
      IconButton(
        icon: Icon(Icons.more_vert, color: iconColor),
        onPressed: widget.onMoreOptions,
      ),
    ];
  }
}
