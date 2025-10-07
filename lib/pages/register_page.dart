import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/my_textfield.dart';
import '../services/auth/auth_service.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  // tap to go to login page
  final void Function()? onTap;

  RegisterPage({super.key, required this.onTap});

  // register method
  void register(BuildContext context) async {
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
        await authService.signUpWithEmailPassword(
          _emailController.text.trim(),
          _pwController.text,
        );
        // Close loading indicator
        if (context.mounted) Navigator.pop(context);
      } catch (e) {
        // Close loading indicator
        if (context.mounted) Navigator.pop(context);

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

            // welcome back massage
            Text(
              "Let's Create an account for you",
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

            // paswword textfield
            MyTextfield(
              hintText: "Password",
              obscureText: true,
              controller: _pwController,
            ),

            const SizedBox(height: 10),

            // paswword confrim textfield
            MyTextfield(
              hintText: "Confirm Password",
              obscureText: true,
              controller: _confirmPwController,
            ),

            const SizedBox(height: 25),

            // login button
            MyButton(text: "Register", onTap: () => register(context)),

            const SizedBox(height: 25),

            // register now
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    "Login now",
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
