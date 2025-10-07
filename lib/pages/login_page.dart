import 'package:chat_app/components/my_button.dart';
import 'package:chat_app/components/my_textfield.dart';
import 'package:chat_app/pages/forgot_password_page.dart';
import 'package:chat_app/pages/phone_login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth/auth_service.dart';

class LoginPage extends StatelessWidget {
  // email and password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // tap to go to register page
  final void Function()? onTap;

  LoginPage({super.key, required this.onTap});

  // login method
  void login(BuildContext context) async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Email Required"),
              content: Text("Please enter your email address."),
            ),
      );
      return;
    }

    if (_pwController.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Password Required"),
              content: Text("Please enter your password."),
            ),
      );
      return;
    }

    // auth service
    final authService = AuthService();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text,
      );
      // Close loading indicator
      if (context.mounted) Navigator.pop(context);
    }
    // catch any errors
    catch (e) {
      // Close loading indicator
      if (context.mounted) Navigator.pop(context);

      // Get user-friendly error message
      String errorCode = e.toString();
      String errorMessage;

      if (errorCode.contains('invalid-credential') ||
          errorCode.contains('user-not-found') ||
          errorCode.contains('wrong-password') ||
          errorCode.contains('INVALID_LOGIN_CREDENTIALS')) {
        errorMessage = "Invalid email or password. Please try again.";
      } else if (errorCode.contains('invalid-email')) {
        errorMessage = "Please enter a valid email address.";
      } else if (errorCode.contains('user-disabled')) {
        errorMessage = "This account has been disabled.";
      } else if (errorCode.contains('network-request-failed')) {
        errorMessage = "Network error. Please check your connection.";
      } else if (errorCode.contains('too-many-requests')) {
        errorMessage = "Too many failed attempts. Please try again later.";
      } else {
        errorMessage = "Login failed: $errorCode";
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Login Failed"),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }

  // Google Sign In
  void signInWithGoogle(BuildContext context) async {
    final authService = AuthService();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await authService.signInWithGoogle();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) Navigator.pop(context);

      String errorCode = e.toString();
      String errorMessage;

      if (errorCode.contains('sign-in-cancelled')) {
        return; // User cancelled, no need to show error
      } else if (errorCode.contains('network-request-failed')) {
        errorMessage = "Network error. Please check your connection.";
      } else if (errorCode.contains(
        'account-exists-with-different-credential',
      )) {
        errorMessage =
            "An account already exists with the same email but different sign-in method.";
      } else {
        errorMessage = "Google sign-in failed: $errorCode";
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Sign In Failed"),
                content: Text(errorMessage),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // logo
            Icon(
              Icons.message,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 50),

            // welcome back message
            Text(
              "Welcome back, you've been missed!",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // email textfield
            MyTextfield(
              hintText: "Email",
              obscureText: false,
              controller: _emailController,
            ),

            const SizedBox(height: 10),

            // password textfield
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            const SizedBox(height: 10),

            // forgot password link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // login button
            MyButton(text: "Login", onTap: () => login(context)),

            const SizedBox(height: 25),

            // Divider with "OR"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Social login buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google sign in button
                  GestureDetector(
                    onTap: () => signInWithGoogle(context),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Phone sign in button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneLoginPage(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Icon(
                        Icons.phone,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Not a member? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Register now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
