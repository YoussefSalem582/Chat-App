import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/profile/profile_service.dart';

class ModernUserTile extends StatefulWidget {
  final String email;
  final String userId;
  final String? displayName;
  final String? photoURL;
  final String? emojiAvatar;
  final bool? hasProfileImage;
  final bool isOnline;
  final VoidCallback onTap;
  final int unreadCount;

  const ModernUserTile({
    super.key,
    required this.email,
    required this.userId,
    this.displayName,
    this.photoURL,
    this.emojiAvatar,
    this.hasProfileImage,
    this.isOnline = true,
    required this.onTap,
    this.unreadCount = 0,
  });

  @override
  State<ModernUserTile> createState() => _ModernUserTileState();
}

class _ModernUserTileState extends State<ModernUserTile> {
  final ProfileService _profileService = ProfileService();
  Uint8List? _imageBytes;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();

    if (widget.hasProfileImage == true) {
      _loadProfileImage();
    }
  }

  Future<void> _loadProfileImage() async {
    setState(() => _isLoadingImage = true);
    try {
      final bytes = await _profileService.getUserProfileImage(widget.userId);
      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.displayName ?? widget.email.split('@')[0];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with online indicator
                Hero(
                  tag: 'avatar_$userName',
                  child: Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade200,
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
                                  : _imageBytes != null
                                  ? Image.memory(
                                    _imageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                  : widget.emojiAvatar != null &&
                                      widget.emojiAvatar!.isNotEmpty
                                  ? Center(
                                    child: Text(
                                      widget.emojiAvatar!,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  )
                                  : Center(
                                    child: Text(
                                      userName.isNotEmpty
                                          ? userName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 22,
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
                      if (widget.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green.shade500,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.grey.shade800
                                        : Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color:
                                  widget.isOnline
                                      ? Colors.green.shade500
                                      : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.isOnline ? 'Active now' : 'Offline',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Unread count badge
                if (widget.unreadCount > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.unreadCount > 99 ? '99+' : '${widget.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                // Arrow Icon
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
