import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/components/components.dart';
import '../services/auth/auth_service.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Send OTP to phone number
  void sendOTP() async {
    String phoneNumber = _phoneController.text.trim();

    // Validate phone number
    if (phoneNumber.isEmpty) {
      _showErrorDialog(
        "Phone Number Required",
        "Please enter your phone number.",
      );
      return;
    }

    // Add country code if not present
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+1$phoneNumber'; // Default to US, change as needed
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
          _showSuccessDialog(
            "OTP Sent!",
            "Please check your phone for the verification code.",
          );
        },
        verificationFailed: (FirebaseAuthException error) {
          setState(() {
            _isLoading = false;
          });
          String errorMessage = _getErrorMessage(error.code);
          _showErrorDialog("Verification Failed", errorMessage);
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          setState(() {
            _isLoading = true;
          });
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) {
              Navigator.pop(context);
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog("Sign In Failed", e.toString());
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("Error", e.toString());
    }
  }

  // Verify OTP and sign in
  void verifyOTP() async {
    String otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showErrorDialog("OTP Required", "Please enter the verification code.");
      return;
    }

    if (_verificationId == null) {
      _showErrorDialog("Error", "Please request OTP first.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithPhoneCredential(_verificationId!, otp);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Navigate back to home (AuthGate will handle navigation)
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      String errorCode = e.toString();
      String errorMessage = _getErrorMessage(errorCode);
      _showErrorDialog("Verification Failed", errorMessage);
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    if (errorCode.contains('invalid-verification-code')) {
      return "Invalid verification code. Please check and try again.";
    } else if (errorCode.contains('session-expired')) {
      return "Verification code has expired. Please request a new one.";
    } else if (errorCode.contains('invalid-phone-number')) {
      return "Invalid phone number format. Please check and try again.";
    } else if (errorCode.contains('too-many-requests')) {
      return "Too many requests. Please try again later.";
    } else if (errorCode.contains('network-request-failed')) {
      return "Network error. Please check your connection.";
    } else {
      return "Error: $errorCode";
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
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

              // Phone icon in circular container
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    size: 60,
                    color: Color(0xFF667eea),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                _codeSent ? "Verify Code" : "Phone Login",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                _codeSent
                    ? "Enter the 6-digit code sent to your phone"
                    : "Enter your phone number to receive a verification code",
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Phone number textfield (only show if code not sent)
              if (!_codeSent) ...[
                MyTextfield(
                  hintText: "Phone Number (with country code)",
                  obscureText: false,
                  controller: _phoneController,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
              ],

              // OTP textfield (only show if code sent)
              if (_codeSent) ...[
                MyTextfield(
                  hintText: "Verification Code",
                  obscureText: false,
                  controller: _otpController,
                  prefixIcon: Icons.sms_outlined,
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Send OTP or Verify button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MyButton(
                    text: _codeSent ? "Verify Code" : "Send OTP",
                    onTap: _codeSent ? verifyOTP : sendOTP,
                  ),

              const SizedBox(height: 24),

              // Resend code button (only show if code sent)
              if (_codeSent) ...[
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _codeSent = false;
                        _verificationId = null;
                        _otpController.clear();
                      });
                    },
                    child: const Text(
                      "Resend Code",
                      style: TextStyle(
                        color: Color(0xFF667eea),
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Back to login
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Back to ",
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Email Login",
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
