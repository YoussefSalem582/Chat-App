import 'package:flutter/material.dart';

import '../components/my_drawer.dart';
import '../components/user_tile.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import 'chat_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey,
        ), // Set drawer icon color to white
      ),
      drawer: MyDrawer(),
      body: _buildUserList(), // Include the user list in the body
    );
  }

  // build a list of users except for the current user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // return list view
        return ListView(
          children:
              snapshot.data!
                  .map<Widget>(
                    (userData) => _buildUserListTile(userData, context),
                  )
                  .toList(),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListTile(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all users except for the current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      // Check if email and uid are not null
      String? email = userData["email"] as String?;
      String? uid = userData["uid"] as String?;

      // Skip if either is null
      if (email == null || uid == null) {
        return Container();
      }

      return UserTile(
        text: email,
        onTap: () {
          // tapped on a user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(receiverEmail: email, receiverID: uid),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
