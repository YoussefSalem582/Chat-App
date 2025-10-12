import 'package:chat_app/components/components.dart';
import 'package:chat_app/pages/forgot_password_page.dart';
import 'package:chat_app/pages/phone_login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  // tap to go to register page
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // email and password text controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // Loading states
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    super.dispose();
  }

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

    // Set loading state
    setState(() => _isLoading = true);

    // try login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text.trim(),
        _pwController.text,
      );
      // Loading will be cleared when widget is disposed after navigation
    }
    // catch any errors
    catch (e) {
      // Stop loading
      if (mounted) {
        setState(() => _isLoading = false);
      }

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

    // Set loading state
    setState(() => _isGoogleLoading = true);

    try {
      await authService.signInWithGoogle();
      // Loading will be cleared when widget is disposed after navigation
    } catch (e) {
      // Stop loading
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }

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
                    Icons.message_rounded,
                    size: 60,
                    color: const Color(0xFF667eea),
                  ),
                ),

                const SizedBox(height: 40),

                // welcome back message
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 40),

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

                const SizedBox(height: 12),

                // forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
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
                        color: const Color(0xFF667eea),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // login button
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF667eea),
                        ),
                      ),
                    )
                    : MyButton(text: "Login", onTap: () => login(context)),

                const SizedBox(height: 32),

                // Divider with "OR"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color:
                            isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color:
                              isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                        color:
                            isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Social login buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google sign in button
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            _isGoogleLoading
                                ? null
                                : () => signInWithGoogle(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child:
                              _isGoogleLoading
                                  ? const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF667eea),
                                            ),
                                      ),
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.google,
                                        color: Color(0xFF667eea),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Google",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              isDarkMode
                                                  ? Colors.white
                                                  : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Phone sign in button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhoneLoginPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                color: const Color(0xFF667eea),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Phone",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Sign Up",
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
