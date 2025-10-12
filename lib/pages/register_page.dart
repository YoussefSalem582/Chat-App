import 'package:flutter/material.dart';
import 'package:chat_app/components/components.dart';
import '../services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // register method
  void register(BuildContext context) async {
    // Validate inputs
    if (_firstNameController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("First Name Required"),
              content: Text("Please enter your first name."),
            ),
      );
      return;
    }

    if (_lastNameController.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Last Name Required"),
              content: Text("Please enter your last name."),
            ),
      );
      return;
    }

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
              content: Text("Please enter a password."),
            ),
      );
      return;
    }

    if (_pwController.text.length < 6) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Weak Password"),
              content: Text("Password must be at least 6 characters long."),
            ),
      );
      return;
    }

    if (_confirmPwController.text.isEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Confirm Password"),
              content: Text("Please confirm your password."),
            ),
      );
      return;
    }

    // get auth service
    final authService = AuthService();

    // passwords match -> create user
    if (_pwController.text == _confirmPwController.text) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Create display name from first and last name
        String displayName =
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

        await authService.signUpWithEmailPassword(
          _emailController.text.trim(),
          _pwController.text,
          displayName: displayName,
        );

        // Close loading indicator immediately after auth completes
        if (context.mounted) {
          await Future.microtask(() {
            if (Navigator.canPop(context)) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          });
        }
      } catch (e) {
        // Close loading indicator
        if (context.mounted) {
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        }

        // Get user-friendly error message
        String errorCode = e.toString();
        String errorMessage;

        if (errorCode.contains('email-already-in-use')) {
          errorMessage =
              "This email is already registered. Please login instead.";
        } else if (errorCode.contains('invalid-email')) {
          errorMessage = "Please enter a valid email address.";
        } else if (errorCode.contains('weak-password')) {
          errorMessage =
              "Password is too weak. Please choose a stronger password.";
        } else if (errorCode.contains('network-request-failed')) {
          errorMessage = "Network error. Please check your connection.";
        } else if (errorCode.contains('operation-not-allowed')) {
          errorMessage = "Registration is currently not allowed.";
        } else {
          errorMessage = "Registration failed: $errorCode";
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text("Registration Failed"),
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
    // passwords don't match -> tell user to fix
    else {
      showDialog(
        context: context,
        builder:
            (context) => const AlertDialog(
              title: Text("Passwords Don't Match"),
              content: Text("Please make sure both passwords are identical."),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // logo
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    size: 60,
                    color: const Color(0xFF667eea),
                  ),
                ),

                const SizedBox(height: 40),

                // welcome message
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Sign up to get started",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

                // first name textfield
                MyTextfield(
                  hintText: "First Name",
                  obscureText: false,
                  controller: _firstNameController,
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // last name textfield
                MyTextfield(
                  hintText: "Last Name",
                  obscureText: false,
                  controller: _lastNameController,
                  prefixIcon: Icons.person_outline,
                ),

                const SizedBox(height: 16),

                // email textfield
                MyTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: _emailController,
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(height: 16),

                // password textfield
                MyTextfield(
                  hintText: "Password",
                  obscureText: true,
                  controller: _pwController,
                  prefixIcon: Icons.lock_outline,
                ),

                const SizedBox(height: 16),

                // confirm password textfield
                MyTextfield(
                  hintText: "Confirm Password",
                  obscureText: true,
                  controller: _confirmPwController,
                  prefixIcon: Icons.lock_outline,
                ),

                const SizedBox(height: 32),

                // register button
                MyButton(text: "Sign Up", onTap: () => register(context)),

                const SizedBox(height: 32),

                // login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF667eea),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
