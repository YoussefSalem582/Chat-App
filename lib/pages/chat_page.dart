import 'package:chat_app/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    super.key,
    required this.receiverEmail,
    required this.receiverID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  // text controller
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  // character count
  int _characterCount = 0;
  static const int _maxCharacters = 500;

  // UI state
  bool _showScrollToBottom = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  // Reply state
  Map<String, dynamic>? _replyToMessage;

  // Selection mode
  bool _isSelectionMode = false;
  Set<String> _selectedMessages = {};

  // Wallpaper and settings
  Color? _chatWallpaperColor;
  final ImagePicker _imagePicker = ImagePicker();
  Set<String> _blockedUsers = {};

  // User emoji avatars
  String? _currentUserEmoji;
  String? _receiverEmoji;

  // Pinned messages
  List<QueryDocumentSnapshot> _pinnedMessages = [];

  // Pagination state
  List<QueryDocumentSnapshot> _messages = [];
  bool _isLoadingMessages = false;
  bool _hasMoreMessages = true;
  DocumentSnapshot? _lastDocument;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Update online status
    _chatService.updateUserStatus(true);

    // Load user emojis
    _loadUserEmojis();

    // add listener for character count
    _messageController.addListener(() {
      setState(() {
        _characterCount = _messageController.text.length;
      });

      // Update typing status
      if (_messageController.text.isNotEmpty) {
        _chatService.setTypingStatus(widget.receiverID, true);
      } else {
        _chatService.setTypingStatus(widget.receiverID, false);
      }
    });

    // add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // then the amount of remaining space can be calculated
        // then scroll down
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // Scroll controller listener for showing scroll to bottom button
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final showButton = _scrollController.offset > 500;
        if (showButton != _showScrollToBottom) {
          setState(() {
            _showScrollToBottom = showButton;
          });
        }
      }
    });

    // wait a bit before scrolling down, then scroll down
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());

    // Load wallpaper preference and blocked users
    _loadChatPreferences();

    // Mark messages as read
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.markMessagesAsRead(
      chatRoomID,
      _authService.getCurrentUser()!.uid,
    );

    // Listen to pinned messages
    _chatService
        .getPinnedMessages(
          _authService.getCurrentUser()!.uid,
          widget.receiverID,
        )
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _pinnedMessages = snapshot.docs;
            });
          }
        });

    // Load initial messages with pagination
    _loadInitialMessages();

    // Listen for new messages in real-time
    _setupRealtimeMessageListener();
  }

  // Setup real-time listener for new messages
  StreamSubscription<QuerySnapshot>? _messageSubscription;

  void _setupRealtimeMessageListener() {
    final currentUserId = _authService.getCurrentUser()!.uid;
    List<String> ids = [currentUserId, widget.receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    _messageSubscription = _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty && _messages.isNotEmpty) {
            final latestMessage = snapshot.docs.first;
            final latestMessageId = latestMessage.id;

            // Check if this is a new message (not in our list)
            final exists = _messages.any((msg) => msg.id == latestMessageId);

            if (!exists && mounted) {
              setState(() {
                // Add new message at the beginning (it's descending order)
                _messages.insert(0, latestMessage);
              });

              // Auto-scroll to bottom if near bottom
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                final currentScroll = _scrollController.offset;
                final isNearBottom = maxScroll - currentScroll < 200;

                if (isNearBottom) {
                  Future.delayed(
                    const Duration(milliseconds: 100),
                    () => scrollDown(),
                  );
                }
              }
            }
          }
        });
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Load initial batch of messages
  Future<void> _loadInitialMessages() async {
    if (_isLoadingMessages) return;

    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final snapshot = await _chatService.getInitialMessages(
        userID: _authService.getCurrentUser()!.uid,
        otherUserID: widget.receiverID,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _messages = snapshot.docs;
          _initialLoadComplete = true;
          _isLoadingMessages = false;
          _hasMoreMessages = snapshot.docs.length >= 50;

          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;
          }
        });

        // Scroll to bottom after initial load
        Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
      print('Error loading initial messages: $e');
    }
  }

  // Load more messages (older messages)
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMessages || !_hasMoreMessages || _lastDocument == null) {
      return;
    }

    setState(() {
      _isLoadingMessages = true;
    });

    try {
      final snapshot = await _chatService.loadMoreMessages(
        userID: _authService.getCurrentUser()!.uid,
        otherUserID: widget.receiverID,
        lastDocument: _lastDocument!,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          if (snapshot.docs.isEmpty) {
            _hasMoreMessages = false;
          } else {
            _messages.addAll(snapshot.docs);
            _lastDocument = snapshot.docs.last;
            _hasMoreMessages = snapshot.docs.length >= 50;
          }
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
      print('Error loading more messages: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _chatService.updateUserStatus(true);
    } else if (state == AppLifecycleState.paused) {
      _chatService.updateUserStatus(false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // dispose of the focus node
    myFocusNode.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    // Cancel message subscription
    _messageSubscription?.cancel();
    // Clear typing status when leaving
    _chatService.setTypingStatus(widget.receiverID, false);
    // Update offline status
    _chatService.updateUserStatus(false);
    super.dispose();
  }

  // scroll controller
  final ScrollController _scrollController = ScrollController();

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // send message
  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();

      // send message with or without reply
      if (_replyToMessage != null) {
        await _chatService.sendReplyMessage(
          widget.receiverID,
          message,
          _replyToMessage!['id'],
          _replyToMessage!['message'],
        );
        setState(() {
          _replyToMessage = null;
        });
      } else {
        await _chatService.sendMessage(widget.receiverID, message);
      }

      // clear text controller
      _messageController.clear();

      // scroll down after sending
      scrollDown();
    }
  }

  // Handle search
  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );

    try {
      final results = await _chatService.searchMessages(chatRoomID, query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
    }
  }

  // Cancel reply
  void _cancelReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  // Reply to message
  void _replyToMsg(Map<String, dynamic> message) {
    setState(() {
      _replyToMessage = message;
      myFocusNode.requestFocus();
    });
  }

  // Toggle selection mode
  void _toggleSelectionMode(String messageId) {
    setState(() {
      if (_isSelectionMode) {
        if (_selectedMessages.contains(messageId)) {
          _selectedMessages.remove(messageId);
          if (_selectedMessages.isEmpty) {
            _isSelectionMode = false;
          }
        } else {
          _selectedMessages.add(messageId);
        }
      } else {
        _isSelectionMode = true;
        _selectedMessages.add(messageId);
      }
    });
  }

  // Delete selected messages
  void _deleteSelectedMessages() {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );

    for (String messageId in _selectedMessages) {
      _chatService.deleteMessage(chatRoomID, messageId);
    }

    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Messages deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: ChatAppBar(
        receiverEmail: widget.receiverEmail,
        receiverID: widget.receiverID,
        isSearching: _isSearching,
        isSelectionMode: _isSelectionMode,
        onSearchToggle: _toggleSearch,
        onMoreOptions: _showChatOptions,
        onDeleteSelected: _deleteSelectedMessages,
        chatService: _chatService,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Pinned messages bar
              if (_pinnedMessages.isNotEmpty)
                PinnedMessagesBar(
                  pinnedMessages: _pinnedMessages,
                  onTap: _showPinnedMessagesDialog,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                ),

              // Search bar (if searching)
              if (_isSearching)
                ChatSearchBar(
                  controller: _searchController,
                  onSearch: _performSearch,
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults.clear();
                    });
                  },
                ),

              // Reply preview (if replying)
              if (_replyToMessage != null)
                ReplyPreviewWidget(
                  replyToMessage: _replyToMessage!,
                  onCancel: _cancelReply,
                ),

              // Selection mode header
              if (_isSelectionMode)
                SelectionHeader(
                  selectedCount: _selectedMessages.length,
                  onCancel: () {
                    setState(() {
                      _selectedMessages.clear();
                      _isSelectionMode = false;
                    });
                  },
                ),

              // display all messages
              Expanded(
                child: Container(
                  color: _chatWallpaperColor ?? Colors.transparent,
                  child: _buildMessageList(),
                ),
              ),

              // user input
              MessageInputBar(
                controller: _messageController,
                focusNode: myFocusNode,
                characterCount: _characterCount,
                maxCharacters: _maxCharacters,
                onSend: sendMessage,
                onAttachment: _showAttachmentOptions,
              ),
            ],
          ),

          // Scroll to bottom button
          if (_showScrollToBottom) ScrollToBottomButton(onPressed: scrollDown),
        ],
      ),
    );
  }

  // Toggle search
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchResults.clear();
      }
    });
  }

  // Show chat options
  void _showChatOptions() {
    final bool isBlocked = _blockedUsers.contains(widget.receiverID);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChatOptionsSheet(
          isUserBlocked: isBlocked,
          onWallpaperTap: () {
            Navigator.pop(context);
            _showWallpaperPicker();
          },
          onNotificationsTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/notification_settings');
          },
          onBlockTap: () {
            Navigator.pop(context);
            if (isBlocked) {
              _unblockUser();
            } else {
              _blockUser();
            }
          },
          onReportTap: () {
            Navigator.pop(context);
            _reportUser();
          },
        );
      },
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;

    // If searching, show search results
    if (_isSearching && _searchResults.isNotEmpty) {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          bool isCurrentUser = result["senderID"] == senderID;

          return ListTile(
            leading: Icon(
              isCurrentUser ? Icons.person : Icons.person_outline,
              color: isCurrentUser ? Colors.blue : Colors.grey,
            ),
            title: Text(
              result["message"],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              _formatTimestamp(result["timestamp"] as Timestamp),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () {
              // TODO: Scroll to message
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchResults.clear();
              });
            },
          );
        },
      );
    }

    // Show loading indicator during initial load
    if (!_initialLoadComplete) {
      return const LoadingIndicator(message: "Loading messages...");
    }

    // No messages yet
    if (_messages.isEmpty) {
      return EmptyState(
        icon: Icons.chat_bubble_outline,
        title: "No messages yet",
        message: "Start the conversation!\nSend your first message below.",
      );
    }

    // Check for typing status and show indicator
    return StreamBuilder<DocumentSnapshot>(
      stream: _chatService.getTypingStatus(
        _authService.getCurrentUser()!.uid,
        widget.receiverID,
      ),
      builder: (context, typingSnapshot) {
        bool isTyping = false;
        if (typingSnapshot.hasData && typingSnapshot.data != null) {
          var data = typingSnapshot.data!.data() as Map<String, dynamic>?;
          isTyping = data?['typing_${widget.receiverID}'] ?? false;
        }

        return RefreshIndicator(
          onRefresh: _loadInitialMessages,
          child: ListView.builder(
            controller: _scrollController,
            reverse: false,
            itemCount:
                _messages.length +
                (_hasMoreMessages ? 1 : 0) +
                (isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              // Load more button at the top
              if (_hasMoreMessages && index == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        _isLoadingMessages
                            ? const Column(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Loading older messages...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                            : OutlinedButton.icon(
                              onPressed: _loadMoreMessages,
                              icon: const Icon(Icons.history, size: 18),
                              label: const Text('Load Older Messages'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                            ),
                  ),
                );
              }

              // Typing indicator at the bottom
              if (isTyping &&
                  index == _messages.length + (_hasMoreMessages ? 1 : 0)) {
                return const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: TypingIndicator(),
                );
              }

              // Adjust index for messages (account for load more button)
              final messageIndex = _hasMoreMessages ? index - 1 : index;
              final doc = _messages.reversed.toList()[messageIndex];

              // Add date separator
              bool showDateSeparator = false;
              if (messageIndex == 0) {
                showDateSeparator = true;
              } else {
                final prevDoc = _messages.reversed.toList()[messageIndex - 1];
                final prevTimestamp =
                    (prevDoc.data() as Map<String, dynamic>)['timestamp']
                        as Timestamp;
                final currentTimestamp =
                    (doc.data() as Map<String, dynamic>)['timestamp']
                        as Timestamp;

                final prevDate = prevTimestamp.toDate();
                final currentDate = currentTimestamp.toDate();

                showDateSeparator =
                    prevDate.day != currentDate.day ||
                    prevDate.month != currentDate.month ||
                    prevDate.year != currentDate.year;
              }

              return Column(
                children: [
                  if (showDateSeparator)
                    MessageDateSeparator(
                      date:
                          (doc.data() as Map<String, dynamic>)['timestamp']
                              .toDate(),
                    ),
                  _buildMessageItem(doc),
                ],
              );
            },
          ),
        );
      },
    );
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

  // build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // is current user
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

    // check if message is deleted
    bool isDeleted = data["isDeleted"] ?? false;

    // Get reactions
    Map<String, dynamic>? reactions =
        data["reactions"] as Map<String, dynamic>?;

    // Get reply data
    Map<String, dynamic>? replyTo = data["replyTo"] as Map<String, dynamic>?;

    // Get chat room ID
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );

    // Check if selected
    bool isSelected = _selectedMessages.contains(doc.id);

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Dismissible(
      key: Key(doc.id),
      direction:
          isCurrentUser
              ? DismissDirection.endToStart
              : DismissDirection.startToEnd,
      background: Container(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.blue.shade100,
        child: Icon(Icons.reply, color: Colors.blue.shade700),
      ),
      confirmDismiss: (direction) async {
        if (!isDeleted) {
          _replyToMsg({
            'id': doc.id,
            'message': data['message'],
            'senderID': data['senderID'],
          });
        }
        return false;
      },
      child: GestureDetector(
        onLongPress: () {
          if (!isDeleted) {
            _toggleSelectionMode(doc.id);
          }
        },
        onTap: () {
          if (_isSelectionMode) {
            _toggleSelectionMode(doc.id);
          }
        },
        child: Container(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          alignment: alignment,
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (_isSelectionMode)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      _toggleSelectionMode(doc.id);
                    },
                  ),
                ),
              Flexible(
                child: Column(
                  crossAxisAlignment:
                      isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    // Reply preview (if this is a reply)
                    if (replyTo != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 60,
                          right: 60,
                          bottom: 4,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 3,
                                height: 30,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  replyTo['message'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ModernChatBubble(
                      message: data["message"],
                      isCurrentUser: isCurrentUser,
                      timestamp: data["timestamp"],
                      isDeleted: isDeleted,
                      messageId: doc.id,
                      chatRoomId: chatRoomID,
                      reactions: reactions,
                      messageType: data["messageType"] as String?,
                      currentUserEmoji: _currentUserEmoji,
                      receiverEmoji: _receiverEmoji,
                      currentUserId: _authService.getCurrentUser()!.uid,
                      receiverId: widget.receiverID,
                      isRead: data["isRead"] ?? false,
                      status: data["status"] as String?,
                      isPinned: data["isPinned"] ?? false,
                      onDelete:
                          (isCurrentUser && !isDeleted)
                              ? () => _deleteMessage(doc.id)
                              : null,
                      onReactionTap:
                          (reaction) => _addReaction(doc.id, reaction),
                      onPin: () => _pinMessage(doc.id),
                      onUnpin: () => _unpinMessage(doc.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // add/toggle reaction to message
  void _addReaction(String messageID, String reaction) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.toggleReaction(chatRoomID, messageID, reaction);
  }

  // delete message
  void _deleteMessage(String messageID) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.deleteMessage(chatRoomID, messageID);
  }

  // Pin message
  void _pinMessage(String messageID) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.pinMessage(chatRoomID, messageID);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message pinned'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Unpin message
  void _unpinMessage(String messageID) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.unpinMessage(chatRoomID, messageID);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message unpinned'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Show pinned messages dialog
  void _showPinnedMessagesDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.push_pin, size: 20),
                const SizedBox(width: 8),
                Text('Pinned Messages (${_pinnedMessages.length})'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pinnedMessages.length,
                itemBuilder: (context, index) {
                  final doc = _pinnedMessages[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final message = data['message'] ?? '';
                  final isDeleted = data['isDeleted'] ?? false;
                  final timestamp = data['timestamp'] as Timestamp?;

                  return ListTile(
                    leading: const Icon(Icons.message, size: 20),
                    title: Text(
                      isDeleted ? 'DELETED MESSAGE' : message,
                      style: TextStyle(
                        fontStyle:
                            isDeleted ? FontStyle.italic : FontStyle.normal,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle:
                        timestamp != null
                            ? Text(
                              _formatTimestamp(timestamp),
                              style: const TextStyle(fontSize: 11),
                            )
                            : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.push_pin_outlined, size: 18),
                      onPressed: () {
                        _unpinMessage(doc.id);
                        if (_pinnedMessages.length == 1) {
                          Navigator.pop(context);
                        }
                      },
                      tooltip: 'Unpin',
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _jumpToMessage(doc.id);
                    },
                  );
                },
              ),
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

  // Jump to specific message
  void _jumpToMessage(String messageID) {
    // For now, just scroll to bottom and show a message
    // In a full implementation, you'd calculate the message position
    scrollDown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Scrolling to message...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  // Load chat preferences
  Future<void> _loadChatPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('wallpaper_${widget.receiverID}');
    if (colorValue != null && mounted) {
      setState(() {
        _chatWallpaperColor = Color(colorValue);
      });
    }

    // Load blocked users
    final blockedList = prefs.getStringList('blocked_users') ?? [];
    if (mounted) {
      setState(() {
        _blockedUsers = blockedList.toSet();
      });
    }
  }

  // Load user emoji avatars
  Future<void> _loadUserEmojis() async {
    try {
      // Load current user emoji
      final currentUserDoc =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(_authService.getCurrentUser()!.uid)
              .get();

      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        if (mounted) {
          setState(() {
            _currentUserEmoji = currentUserData?['emojiAvatar'];
          });
        }
      }

      // Load receiver emoji
      final receiverDoc =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(widget.receiverID)
              .get();

      if (receiverDoc.exists) {
        final receiverData = receiverDoc.data();
        if (mounted) {
          setState(() {
            _receiverEmoji = receiverData?['emojiAvatar'];
          });
        }
      }
    } catch (e) {
      print('Error loading user emojis: $e');
    }
  }

  // Save wallpaper preference
  Future<void> _saveWallpaperPreference(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wallpaper_${widget.receiverID}', color.value);
    if (mounted) {
      setState(() {
        _chatWallpaperColor = color;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      // Request storage permission first
      final storageStatus = await Permission.photos.request();

      if (!storageStatus.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Storage permission is required to select images'),
            ),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        // Send image path as message with special prefix
        await _chatService.sendMessage(
          widget.receiverID,
          '📷 Image:\n${image.path}',
          messageType: 'image',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image sent successfully!')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image picker not available: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  // Take photo with camera
  Future<void> _takePhoto() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final XFile? photo = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 70,
        );

        if (photo != null) {
          await _chatService.sendMessage(
            widget.receiverID,
            '📸 Camera:\n${photo.path}',
            messageType: 'image',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo sent successfully!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission denied')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera not available: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error taking photo: $e')));
      }
    }
  }

  // Pick document
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileSize = file.size;
        final filePath = file.path ?? '';

        await _chatService.sendMessage(
          widget.receiverID,
          '📄 Document: $fileName\n(${_formatFileSize(fileSize)})\n$filePath',
          messageType: 'document',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document sent successfully!')),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker not available: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
      }
    }
  }

  // Share location
  Future<void> _shareLocation() async {
    try {
      // Request location permission
      final status = await Permission.location.request();

      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Getting your location...')),
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String locationText = '📍 Location: ';
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationText += '${place.locality ?? ''}, ${place.country ?? ''}\n';
        }
        locationText +=
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Long: ${position.longitude.toStringAsFixed(6)}';

        await _chatService.sendMessage(
          widget.receiverID,
          locationText,
          messageType: 'location',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location sent successfully!')),
          );
        }
      } catch (e) {
        // If geocoding fails, just send coordinates
        await _chatService.sendMessage(
          widget.receiverID,
          '📍 Location: \n'
          'Lat: ${position.latitude.toStringAsFixed(6)}, '
          'Long: ${position.longitude.toStringAsFixed(6)}',
          messageType: 'location',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location sent successfully!')),
          );
        }
      }
    } on TimeoutException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location request timed out. Please try again.'),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location service error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      }
    }
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Show wallpaper picker
  void _showWallpaperPicker() {
    showDialog(
      context: context,
      builder:
          (context) => WallpaperPickerDialog(
            currentColor: _chatWallpaperColor,
            onColorSelected: _saveWallpaperPreference,
          ),
    );
  }

  // Block user
  Future<void> _blockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Block User'),
            content: Text(
              'Are you sure you want to block ${widget.receiverEmail}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Block'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      _blockedUsers.add(widget.receiverID);
      await prefs.setStringList('blocked_users', _blockedUsers.toList());

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User blocked successfully')),
        );
      }
    }
  }

  // Unblock user
  Future<void> _unblockUser() async {
    final prefs = await SharedPreferences.getInstance();
    _blockedUsers.remove(widget.receiverID);
    await prefs.setStringList('blocked_users', _blockedUsers.toList());

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked successfully')),
      );
    }
  }

  // Report user
  void _reportUser() {
    final reasons = [
      'Spam',
      'Harassment',
      'Inappropriate content',
      'Impersonation',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Report User'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Report ${widget.receiverEmail} for:'),
                      const SizedBox(height: 16),
                      ...reasons.map(
                        (reason) => RadioListTile<String>(
                          title: Text(reason),
                          value: reason,
                          groupValue: selectedReason,
                          onChanged: (value) {
                            setDialogState(() {
                              selectedReason = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed:
                          selectedReason == null
                              ? null
                              : () async {
                                // Save report to Firestore
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('reports')
                                      .add({
                                        'reportedUserId': widget.receiverID,
                                        'reportedUserEmail':
                                            widget.receiverEmail,
                                        'reportedBy':
                                            _authService.getCurrentUser()!.uid,
                                        'reportedByEmail':
                                            _authService
                                                .getCurrentUser()!
                                                .email,
                                        'reason': selectedReason,
                                        'timestamp': Timestamp.now(),
                                      });

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Report submitted successfully',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error submitting report: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Report'),
                    ),
                  ],
                ),
          ),
    );
  }

  // Show attachment options
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AttachmentOptionsSheet(
          onImageTap: () {
            Navigator.pop(context);
            _pickImage();
          },
          onCameraTap: () {
            Navigator.pop(context);
            _takePhoto();
          },
          onDocumentTap: () {
            Navigator.pop(context);
            _pickDocument();
          },
          onLocationTap: () {
            Navigator.pop(context);
            _shareLocation();
          },
        );
      },
    );
  }
}
