import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/admin_screen.dart';
import '../../pages/home_page.dart';
import '../../pages/onboarding_screen.dart';
import 'login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _shouldShowOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('onboarding_complete') ?? false;
    return !hasSeenOnboarding;
  }

  bool _isAdmin(User? user) {
    // Check if user email is admin email
    return user?.email == 'admin@gmail.com';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            // Check if user is admin
            if (_isAdmin(snapshot.data)) {
              return const AdminScreen();
            }
            return HomePage();
          }
          // user is not logged in - check if should show onboarding
          else {
            return FutureBuilder<bool>(
              future: _shouldShowOnboarding(),
              builder: (context, onboardingSnapshot) {
                if (onboardingSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF667eea),
                      ),
                    ),
                  );
                }

                final showOnboarding = onboardingSnapshot.data ?? false;
                return showOnboarding
                    ? const OnboardingScreen()
                    : const LoginOrRegister();
              },
            );
          }
        },
      ),
    );
  }
}
