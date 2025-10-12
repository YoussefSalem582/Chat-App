import 'package:chat_app/pages/notification_settings_page.dart';
import 'package:chat_app/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Settings"),
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
          // Dark mode toggle
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // dark mode
                const Text("Dark Mode"),

                // switch toggle
                CupertinoSwitch(
                  value:
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).isDarkMode,
                  onChanged:
                      (value) =>
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).toggleTheme(),
                ),
              ],
            ),
          ),

          // Notification settings button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: ListTile(
              leading: Icon(
                Icons.notifications,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Notification Settings"),
              subtitle: const Text("Manage push notifications"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
