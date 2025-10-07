import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/components/empty_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/chat_bubble.dart';
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

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth services
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for textfield focus
  FocusNode myFocusNode = FocusNode();

  // character count
  int _characterCount = 0;
  static const int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();

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

    // wait a bit before scrolling down, then scroll down
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    // dispose of the focus node
    myFocusNode.dispose();
    _messageController.dispose();
    // Clear typing status when leaving
    _chatService.setTypingStatus(widget.receiverID, false);
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
      // send message
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text.trim(),
      );

      // clear text controller
      _messageController.clear();

      // scroll down after sending
      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _chatService.getTypingStatus(
            _authService.getCurrentUser()!.uid,
            widget.receiverID,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              var data = snapshot.data!.data() as Map<String, dynamic>?;
              bool isTyping = data?['typing_${widget.receiverID}'] ?? false;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.receiverEmail),
                  if (isTyping)
                    Text(
                      'typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              );
            }
            return Text(widget.receiverEmail);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey,
        ), // Set drawer icon color to white
      ),
      body: Column(
        children: [
          // display all messages
          Expanded(child: _buildMessageList()),

          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Error loading messages",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading messages..."),
              ],
            ),
          );
        }

        // No messages yet
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return EmptyState(
            icon: Icons.chat_bubble_outline,
            title: "No messages yet",
            message: "Start the conversation!\nSend your first message below.",
          );
        }

        // return list view
        return ListView(
          controller: _scrollController,
          reverse: false, // This makes the list view start from the bottom
          children:
              snapshot.data!.docs.reversed
                  .map((doc) => _buildMessageItem(doc))
                  .toList(),
        );
      },
    );
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

    // Get chat room ID
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );

    // align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
            timestamp: data["timestamp"],
            isDeleted: isDeleted,
            messageId: doc.id,
            chatRoomId: chatRoomID,
            reactions: reactions,
            onDelete:
                (isCurrentUser && !isDeleted)
                    ? () => _deleteMessage(doc.id)
                    : null,
            onReactionTap: (reaction) => _addReaction(doc.id, reaction),
          ),
        ],
      ),
    );
  }

  // add reaction to message
  void _addReaction(String messageID, String reaction) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.addReaction(chatRoomID, messageID, reaction);
  }

  // delete message
  void _deleteMessage(String messageID) {
    String chatRoomID = _chatService.getChatRoomID(
      _authService.getCurrentUser()!.uid,
      widget.receiverID,
    );
    _chatService.deleteMessage(chatRoomID, messageID);
  }

  // build message input
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Column(
        children: [
          // Character counter
          if (_characterCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$_characterCount/$_maxCharacters',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          _characterCount > _maxCharacters
                              ? Colors.red
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 5),
          // Input row
          Row(
            children: [
              // textfield should take up most of the space
              Expanded(
                child: MyTextfield(
                  controller: _messageController,
                  hintText: "Type a Message",
                  obscureText: false,
                  focusNode: myFocusNode,
                ),
              ),

              // send button
              Container(
                decoration: BoxDecoration(
                  color:
                      _characterCount > 0 && _characterCount <= _maxCharacters
                          ? Colors.green
                          : Colors.grey,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 25.0),
                child: IconButton(
                  onPressed:
                      _characterCount > 0 && _characterCount <= _maxCharacters
                          ? sendMessage
                          : null,
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
