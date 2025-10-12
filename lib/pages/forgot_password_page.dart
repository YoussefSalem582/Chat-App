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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // Lock icon in circular container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 60,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              const Text(
                "Forgot Password?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Enter your email address and we'll send you a link to reset your password",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Email textfield
              MyTextfield(
                hintText: "Email",
                obscureText: false,
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 32),

              // Send reset email button
              MyButton(
                text: "Send Reset Link",
                onTap: () => sendPasswordReset(context),
              ),

              const SizedBox(height: 32),

              // Back to login
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Remember your password? ",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
