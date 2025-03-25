import 'package:chat_app/components/my_drawer.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    // get auth service
    final _auth = AuthService();
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(147, 147, 147, 1.0),
        title: Text("Home", style: TextStyle(color: Colors.white)),
        actions: [
          // logout button
          IconButton(
            onPressed: logout,
            icon: Icon(Icons.logout, color: Colors.white),
          ),
        ],
        iconTheme: IconThemeData(
          color: Colors.white,
        ), // Set drawer icon color to white
      ),
      drawer: MyDrawer(),
    );
  }
}
