import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/onboarding_screen.dart';
import '../../pages/profile_page.dart';
import '../../pages/settings_page.dart';
import '../../services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    // Sign out first
    final auth = AuthService();
    await auth.signOut();

    // Reset onboarding flag so user sees it again
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');

    // Navigate to onboarding screen and remove all previous routes
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Column(
            children: [
              // logo
              Column(
                children: [
                  DrawerHeader(
                    child: Center(
                      child: Icon(
                        Icons.message,
                        color: Theme.of(context).colorScheme.primary,
                        size: 60,
                      ),
                    ),
                  ),
                ],
              ),

              // home list title
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),

              // profile list title
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("P R O F I L E"),
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // navigate to profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
              ),

              // settings list title
              Padding(
                padding: EdgeInsets.only(left: 25),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () {
                    // pop the drawer
                    Navigator.pop(context);

                    // navigate to settings page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Spacer(),

          // logout list title
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: ListTile(
              title: const Text("L O G O U T"),
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
