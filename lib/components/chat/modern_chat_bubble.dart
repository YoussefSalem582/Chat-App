import 'package:chat_app/components/chat/message_reaction_picker.dart';
import 'package:chat_app/components/chat/link_preview_widget.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import '../../services/profile/profile_service.dart';

class ModernChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final Timestamp timestamp;
  final VoidCallback? onDelete;
  final bool isDeleted;
  final String messageId;
  final String chatRoomId;
  final Map<String, dynamic>? reactions;
  final Function(String)? onReactionTap;
  final String? messageType; // 'text', 'image', 'document', 'location'
  final String? currentUserEmoji;
  final String? receiverEmoji;
  final String? currentUserId;
  final String? receiverId;
  final bool isRead; // Track if message has been read
  final String?
  status; // Message status: 'pending', 'sent', 'delivered', 'read'
  final bool isPinned; // Track if message is pinned
  final VoidCallback? onPin; // Callback to pin message
  final VoidCallback? onUnpin; // Callback to unpin message

  const ModernChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
    this.onDelete,
    this.isDeleted = false,
    required this.messageId,
    required this.chatRoomId,
    this.reactions,
    this.onReactionTap,
    this.messageType,
    this.currentUserEmoji,
    this.receiverEmoji,
    this.currentUserId,
    this.receiverId,
    this.isRead = false,
    this.status, // Optional status parameter
    this.isPinned = false,
    this.onPin,
    this.onUnpin,
  });

  @override
  State<ModernChatBubble> createState() => _ModernChatBubbleState();
}

class _ModernChatBubbleState extends State<ModernChatBubble> {
  final ProfileService _profileService = ProfileService();
  Uint8List? _currentUserImageBytes;
  Uint8List? _receiverImageBytes;
  bool _isLoadingCurrentUserImage = false;
  bool _isLoadingReceiverImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImages();
  }

  Future<void> _loadProfileImages() async {
    // Load current user's profile image
    if (widget.currentUserId != null) {
      setState(() => _isLoadingCurrentUserImage = true);
      try {
        final bytes = await _profileService.getUserProfileImage(
          widget.currentUserId!,
        );
        if (mounted) {
          setState(() {
            _currentUserImageBytes = bytes;
            _isLoadingCurrentUserImage = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingCurrentUserImage = false);
        }
      }
    }

    // Load receiver's profile image
    if (widget.receiverId != null) {
      setState(() => _isLoadingReceiverImage = true);
      try {
        final bytes = await _profileService.getUserProfileImage(
          widget.receiverId!,
        );
        if (mounted) {
          setState(() {
            _receiverImageBytes = bytes;
            _isLoadingReceiverImage = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoadingReceiverImage = false);
        }
      }
    }
  }

  // URL detection helper methods
  bool _containsUrl(String text) {
    final urlPattern = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    return urlPattern.hasMatch(text);
  }

  String? _extractUrl(String text) {
    final urlPattern = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final DateTime now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      int hour = dateTime.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) {
        hour = hour - 12;
      } else if (hour == 0) {
        hour = 12;
      }
      return '$hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Parse image message to get actual file path
  String? _getImagePath(String message) {
    if (message.startsWith('📷 Image:') || message.startsWith('📸 Camera:')) {
      final parts = message.split('\n');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    return null;
  }

  // Parse document message to get file info
  Map<String, String>? _getDocumentInfo(String message) {
    if (message.startsWith('📄 Document:')) {
      final lines = message.split('\n');
      if (lines.length >= 2) {
        final fileName = lines[0].replaceFirst('📄 Document:', '').trim();
        final filePath = lines.length > 2 ? lines[2].trim() : '';
        return {'name': fileName, 'path': filePath};
      }
    }
    return null;
  }

  // Parse location message to get coordinates
  Map<String, String>? _getLocationInfo(String message) {
    if (message.startsWith('📍 Location:')) {
      final regex = RegExp(r'Lat:\s*([-\d.]+),\s*Long:\s*([-\d.]+)');
      final match = regex.firstMatch(message);
      if (match != null) {
        return {
          'lat': match.group(1)!,
          'long': match.group(2)!,
          'fullText': message,
        };
      }
    }
    return null;
  }

  Widget _buildMessageContent(bool isDarkMode) {
    // Check for image
    final imagePath = _getImagePath(widget.message);
    if (imagePath != null) {
      return _buildImageMessage(imagePath, isDarkMode);
    }

    // Check for document
    final docInfo = _getDocumentInfo(widget.message);
    if (docInfo != null) {
      return _buildDocumentMessage(docInfo, isDarkMode);
    }

    // Check for location
    final locationInfo = _getLocationInfo(widget.message);
    if (locationInfo != null) {
      return _buildLocationMessage(locationInfo, isDarkMode);
    }

    // Default text message
    return _buildTextMessage(isDarkMode);
  }

  Widget _buildTextMessage(bool isDarkMode) {
    final containsUrl = _containsUrl(widget.message);
    final url = containsUrl ? _extractUrl(widget.message) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.message,
          style: TextStyle(
            fontSize: 15,
            color:
                widget.isCurrentUser
                    ? Colors.white
                    : (isDarkMode ? Colors.white : Colors.black87),
            height: 1.4,
            fontStyle: widget.isDeleted ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        // Show link preview if URL is detected
        if (containsUrl && url != null) ...[
          const SizedBox(height: 8),
          LinkPreviewWidget(url: url),
        ],
        const SizedBox(height: 4),
        _buildTimestampRow(isDarkMode),
      ],
    );
  }

  Widget _buildImageMessage(String imagePath, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(imagePath),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                color: Colors.grey.shade300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Image not found',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        _buildTimestampRow(isDarkMode),
      ],
    );
  }

  Widget _buildDocumentMessage(Map<String, String> docInfo, bool isDarkMode) {
    final filePath = docInfo['path'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            if (filePath.isNotEmpty) {
              try {
                final file = File(filePath);
                if (await file.exists()) {
                  // Use OpenFilex to open the file with system default app
                  final result = await OpenFilex.open(filePath);
                  if (result.type != ResultType.done) {
                    print('Could not open file: ${result.message}');
                  }
                } else {
                  print('File not found: $filePath');
                }
              } catch (e) {
                print('Error opening document: $e');
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  widget.isCurrentUser
                      ? Colors.white.withOpacity(0.2)
                      : (isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.insert_drive_file,
                  color:
                      widget.isCurrentUser
                          ? Colors.white
                          : (isDarkMode ? Colors.white : Colors.black87),
                  size: 32,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        docInfo['name'] ?? 'Document',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              widget.isCurrentUser
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.white
                                      : Colors.black87),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              widget.isCurrentUser
                                  ? Colors.white.withOpacity(0.7)
                                  : (isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTimestampRow(isDarkMode),
      ],
    );
  }

  Widget _buildLocationMessage(
    Map<String, String> locationInfo,
    bool isDarkMode,
  ) {
    final lat = locationInfo['lat'] ?? '';
    final long = locationInfo['long'] ?? '';

    // Extract just the location name/address (without the emoji and "Location:" prefix)
    String locationName =
        locationInfo['fullText']
            ?.split('\n')
            .firstWhere(
              (line) => line.startsWith('📍 Location:'),
              orElse: () => '📍 Location: Egypt',
            )
            .replaceFirst('📍 Location:', '')
            .trim() ??
        'Egypt';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            try {
              final url =
                  'https://www.google.com/maps/search/?api=1&query=$lat,$long';
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                // Try alternative method
                final geoUri = Uri.parse('geo:$lat,$long?q=$lat,$long');
                if (await canLaunchUrl(geoUri)) {
                  await launchUrl(geoUri);
                }
              }
            } catch (e) {
              print('Error opening maps: $e');
            }
          },
          child: Container(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  widget.isCurrentUser
                      ? Colors.white.withOpacity(0.15)
                      : (isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    widget.isCurrentUser
                        ? Colors.white.withOpacity(0.2)
                        : (isDarkMode
                            ? Colors.grey.shade700
                            : Colors.grey.shade300),
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
                        color:
                            widget.isCurrentUser
                                ? Colors.white.withOpacity(0.2)
                                : Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color:
                            widget.isCurrentUser
                                ? Colors.white
                                : Colors.red.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color:
                                  widget.isCurrentUser
                                      ? Colors.white.withOpacity(0.8)
                                      : (isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  widget.isCurrentUser
                                      ? Colors.white
                                      : (isDarkMode
                                          ? Colors.white
                                          : Colors.black87),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.isCurrentUser
                            ? Colors.white.withOpacity(0.2)
                            : (isDarkMode
                                ? Colors.grey.shade700.withOpacity(0.5)
                                : Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map,
                        size: 14,
                        color:
                            widget.isCurrentUser
                                ? Colors.white.withOpacity(0.9)
                                : (isDarkMode
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade700),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap to open in maps',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:
                              widget.isCurrentUser
                                  ? Colors.white.withOpacity(0.9)
                                  : (isDarkMode
                                      ? Colors.grey.shade300
                                      : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildTimestampRow(isDarkMode),
      ],
    );
  }

  Widget _buildTimestampRow(bool isDarkMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTimestamp(widget.timestamp),
          style: TextStyle(
            fontSize: 11,
            color:
                widget.isCurrentUser
                    ? Colors.white.withOpacity(0.8)
                    : (isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
          ),
        ),
        if (widget.isCurrentUser && !widget.isDeleted) ...[
          const SizedBox(width: 4),
          _buildStatusIcon(),
        ],
      ],
    );
  }

  // Build status icon based on message status
  Widget _buildStatusIcon() {
    final status = widget.status ?? (widget.isRead ? 'read' : 'sent');

    switch (status) {
      case 'pending':
        return Icon(
          Icons.access_time,
          size: 14,
          color: Colors.white.withOpacity(0.6),
        );
      case 'sent':
        return Icon(Icons.done, size: 14, color: Colors.white.withOpacity(0.8));
      case 'delivered':
        return Icon(
          Icons.done_all,
          size: 14,
          color: Colors.white.withOpacity(0.8),
        );
      case 'read':
        return Icon(Icons.done_all, size: 14, color: Colors.lightBlueAccent);
      default:
        return Icon(Icons.done, size: 14, color: Colors.white.withOpacity(0.8));
    }
  }

  // Build reaction bubbles with counts and current user highlight
  List<Widget> _buildReactionBubbles(bool isDarkMode) {
    // Group reactions by emoji and count them
    Map<String, List<String>> reactionGroups = {};

    widget.reactions!.forEach((userId, emoji) {
      if (reactionGroups.containsKey(emoji)) {
        reactionGroups[emoji]!.add(userId);
      } else {
        reactionGroups[emoji] = [userId];
      }
    });

    // Build reaction bubble for each unique emoji
    return reactionGroups.entries.map((entry) {
      final emoji = entry.key;
      final userIds = entry.value;
      final count = userIds.length;
      final currentUserReacted =
          widget.currentUserId != null &&
          userIds.contains(widget.currentUserId);

      return GestureDetector(
        onTap: () {
          // Toggle reaction - if user already reacted with this, remove it
          if (currentUserReacted) {
            _removeCurrentUserReaction();
          } else {
            // Add this reaction
            if (widget.onReactionTap != null) {
              widget.onReactionTap!(emoji);
            }
          }
        },
        onLongPress: () {
          // Show who reacted
          _showReactionUsers(emoji, userIds);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                currentUserReacted
                    ? (isDarkMode ? Colors.blue.shade800 : Colors.blue.shade100)
                    : (isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            border:
                currentUserReacted
                    ? Border.all(
                      color:
                          isDarkMode
                              ? Colors.blue.shade400
                              : Colors.blue.shade600,
                      width: 1.5,
                    )
                    : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              if (count > 1) ...[
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color:
                        currentUserReacted
                            ? (isDarkMode
                                ? Colors.blue.shade200
                                : Colors.blue.shade800)
                            : (isDarkMode
                                ? Colors.grey.shade300
                                : Colors.grey.shade700),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  // Remove current user's reaction
  void _removeCurrentUserReaction() {
    if (widget.currentUserId == null) return;

    // Find current user's reaction
    String? currentReaction;
    widget.reactions?.forEach((userId, emoji) {
      if (userId == widget.currentUserId) {
        currentReaction = emoji;
      }
    });

    if (currentReaction != null) {
      // Call remove reaction through chat service
      // This will be handled by the parent via onReactionTap with a special indicator
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed reaction $currentReaction'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Show who reacted with this emoji
  void _showReactionUsers(String emoji, List<String> userIds) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reacted with $emoji'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${userIds.length} ${userIds.length == 1 ? 'person' : 'people'} reacted',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ...userIds.map(
                  (userId) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userId == widget.currentUserId ? 'You' : 'User',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    return GestureDetector(
      onLongPress: () {
        _showMessageOptions(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment:
              widget.isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  widget.isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isCurrentUser) ...[
                  // Receiver's avatar with emoji support
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          _isLoadingReceiverImage
                              ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                              )
                              : _receiverImageBytes != null
                              ? Image.memory(
                                _receiverImageBytes!,
                                fit: BoxFit.cover,
                              )
                              : widget.receiverEmoji != null &&
                                  widget.receiverEmoji!.isNotEmpty
                              ? Center(
                                child: Text(
                                  widget.receiverEmoji!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                              : Icon(
                                Icons.person,
                                size: 16,
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade600,
                              ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          widget.isCurrentUser
                              ? LinearGradient(
                                colors:
                                    isDarkMode
                                        ? [
                                          Colors.blue.shade700,
                                          Colors.blue.shade600,
                                        ]
                                        : [
                                          Colors.blue.shade500,
                                          Colors.blue.shade600,
                                        ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                              : null,
                      color:
                          !widget.isCurrentUser
                              ? (isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200)
                              : null,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(
                          widget.isCurrentUser ? 20 : 4,
                        ),
                        bottomRight: Radius.circular(
                          widget.isCurrentUser ? 4 : 20,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildMessageContent(isDarkMode)],
                    ),
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(width: 8),
                  // Current user's avatar with emoji support
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          _isLoadingCurrentUserImage
                              ? Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : _currentUserImageBytes != null
                              ? Image.memory(
                                _currentUserImageBytes!,
                                fit: BoxFit.cover,
                              )
                              : widget.currentUserEmoji != null &&
                                  widget.currentUserEmoji!.isNotEmpty
                              ? Center(
                                child: Text(
                                  widget.currentUserEmoji!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                              : const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.white,
                              ),
                    ),
                  ),
                ],
              ],
            ),
            // Display reactions with counts
            if (widget.reactions != null && widget.reactions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 30, right: 30),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _buildReactionBubbles(isDarkMode),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    if (widget.isDeleted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: MessageReactionPicker(
                      onReactionSelected: (reaction) {
                        Navigator.pop(context);
                        if (widget.onReactionTap != null) {
                          widget.onReactionTap!(reaction);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reacted with $reaction'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy Message'),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.message));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Message copied to clipboard'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                // Pin/Unpin option
                ListTile(
                  leading: Icon(
                    widget.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  ),
                  title: Text(
                    widget.isPinned ? 'Unpin Message' : 'Pin Message',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.isPinned && widget.onUnpin != null) {
                      widget.onUnpin!();
                    } else if (!widget.isPinned && widget.onPin != null) {
                      widget.onPin!();
                    }
                  },
                ),
                if (widget.isCurrentUser && widget.onDelete != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Delete Message',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _confirmDelete(context);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onDelete != null) {
                    widget.onDelete!();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Message deleted'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
