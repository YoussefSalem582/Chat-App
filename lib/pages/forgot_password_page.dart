import 'package:flutter/material.dart';
import 'package:chat_app/components/components.dart';
import '../services/auth/auth_service.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  // send password reset email
  void sendPasswordReset(BuildContext context) async {
    // Validate email
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

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Get auth service
    final authService = AuthService();

    try {
      await authService.sendPasswordResetEmail(_emailController.text.trim());

      // Close loading indicator
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Email Sent!"),
                content: Text(
                  "Password reset link has been sent to ${_emailController.text.trim()}.\n\nPlease check your email and follow the instructions to reset your password.",
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to login
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) Navigator.pop(context);

      // Parse error
      String errorCode = e.toString();
      String errorMessage;

      if (errorCode.contains('user-not-found')) {
        errorMessage = "No account found with this email address.";
      } else if (errorCode.contains('invalid-email')) {
        errorMessage = "Please enter a valid email address.";
      } else if (errorCode.contains('network-request-failed')) {
        errorMessage = "Network error. Please check your connection.";
      } else {
        errorMessage = "Failed to send reset email: $errorCode";
      }

      if (context.mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Error"),
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
      appBar: AppBar(
        title: const Text("Forgot Password"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(
                Icons.lock_reset,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 30),

              // Title
              Text(
                "Reset Your Password",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 15),

              // Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Enter your email address and we'll send you a link to reset your password.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 30),

              // Email textfield
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
              ),

              const SizedBox(height: 25),

              // Send reset email button
              MyButton(
                text: "Send Reset Link",
                onTap: () => sendPasswordReset(context),
              ),

              const SizedBox(height: 25),

              // Back to login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Remember your password? ",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      "Login",
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
      ),
    );
  }
}
