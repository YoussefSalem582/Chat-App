import 'package:flutter/material.dart';

import '../components/my_drawer.dart';
import '../components/user_tile.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // search controller
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          // User list
          Expanded(child: _buildUserList()),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  "Error loading users",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${snapshot.error}",
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
                Text("Loading users..."),
              ],
            ),
          );
        }

        // return list view
        return ListView(
          children:
              snapshot.data!
                  .where((userData) {
                    // Filter by search query
                    if (_searchQuery.isEmpty) return true;
                    // Handle null email safely
                    String? email = userData["email"];
                    if (email == null) return false;
                    return email.toLowerCase().contains(_searchQuery);
                  })
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
    // Handle null values safely
    String? email = userData["email"];
    String? uid = userData["uid"];
    String? displayName = userData["displayName"];
    String? phoneNumber = userData["phoneNumber"];

    // Skip if essential data is missing
    if (email == null && phoneNumber == null && displayName == null) {
      return Container();
    }

    // Create display text (prefer email, fallback to displayName or phone)
    String displayText = email ?? displayName ?? phoneNumber ?? "Unknown User";

    // display all users except for the current user
    if (email != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: displayText,
        onTap: () {
          // tapped on a user -> go to chat page
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
    } else {
      return Container();
    }
  }
}
