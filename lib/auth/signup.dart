import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import '../services/firebase_service.dart';
import '../services/google_sign_in_helper.dart';

void _showTermsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Acceptance of Terms\n'
                'By using BloomCycle, you agree to these terms and conditions.\n\n'
                '2. Use License\n'
                'Permission is granted to temporarily download one copy of materials on BloomCycle for personal, non-commercial transitory viewing.\n\n'
                '3. Disclaimer\n'
                'The materials and information provided on BloomCycle are provided on an "as is" basis without warranties of any kind.\n\n'
                '4. Limitations of Liability\n'
                'In no event shall BloomCycle be liable for any direct, indirect, incidental, special, or consequential damages.\n\n'
                '5. Accuracy of Materials\n'
                'The materials appearing on BloomCycle could include technical, typographical, or photographic errors.\n\n'
                '6. Links\n'
                'BloomCycle has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showPrivacyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. Information Collection\n'
                'We collect information you provide directly, such as when you create an account or contact us.\n\n'
                '2. Use of Information\n'
                'Your information is used to provide, improve, and maintain BloomCycle services.\n\n'
                '3. Data Security\n'
                'We implement appropriate technical and organizational measures to protect your data.\n\n'
                '4. Third-Party Services\n'
                'BloomCycle may use third-party services for analytics and other functions.\n\n'
                '5. Your Rights\n'
                'You have the right to access, modify, or delete your personal information.\n\n'
                '6. Contact Us\n'
                'If you have questions about this privacy policy, please contact us at privacy@bloomcycle.com',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isCreatingAccount = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms to continue.')),
      );
      return;
    }

    final signupInfo = await _collectGoogleSignupData();
    if (signupInfo == null) {
      return;
    }

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await signInWithGoogleCredential();

      if (result == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled.')),
        );
        return;
      }

      final userCredential = result.userCredential;
      final user = userCredential.user;
      final googleUser = result.googleAccount;

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not complete Google sign-in. Please try again.',
            ),
          ),
        );
        return;
      }

      final providerData = user.providerData.isNotEmpty
          ? user.providerData.first
          : null;

      final googleDisplayName =
          (googleUser?.displayName ?? user.displayName ?? '').trim();
      final nameParts = googleDisplayName
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();

      String firstName = _firstNameController.text.trim();
      String lastName = _lastNameController.text.trim();

      if (firstName.isEmpty && nameParts.isNotEmpty) {
        firstName = nameParts.first;
      }
      if (lastName.isEmpty && nameParts.length > 1) {
        lastName = nameParts.sublist(1).join(' ');
      }

      String displayName = [
        firstName,
        lastName,
      ].where((value) => value.isNotEmpty).join(' ').trim();
      if (displayName.isEmpty) {
        displayName = googleDisplayName.isNotEmpty
            ? googleDisplayName
            : signupInfo.email;
      }

      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      try {
        final emailCredential = EmailAuthProvider.credential(
          email: signupInfo.email,
          password: signupInfo.password,
        );
        await user.linkWithCredential(emailCredential);
      } on FirebaseAuthException catch (e) {
        final code = e.code;
        if (code != 'provider-already-linked' &&
            code != 'credential-already-in-use') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not link email/password: ${e.message ?? code}',
              ),
            ),
          );
          await FirebaseAuth.instance.signOut();
          return;
        }
      }

      await FirebaseService.createUser(user.uid, {
        'profile': {
          'firstName': firstName,
          'lastName': lastName,
          'displayName': displayName,
          'email': signupInfo.email,
          'photoURL': user.photoURL,
          'phoneNumber': user.phoneNumber,
          'provider': 'google',
          'providerId': providerData?.providerId,
        },
        'onboarding': {'completed': false, 'startedAt': DateTime.now()},
        'lastSignInAt': DateTime.now(),
      });

      await user.sendEmailVerification();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created! Please verify your email before signing in.',
          ),
        ),
      );

      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<_GoogleSignupInfo?> _collectGoogleSignupData() async {
    final emailController = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter your email'),
              content: TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  errorText: errorText,
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setState(() {
                      errorText = null;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(null);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value = emailController.text.trim();
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (value.isEmpty || !emailRegex.hasMatch(value)) {
                      setState(() {
                        errorText = 'Please enter a valid email address.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: const Text('Next'),
                ),
              ],
            );
          },
        );
      },
    );

    if (email == null) {
      return null;
    }

    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? errorText;
        bool obscure = true;
        bool obscureConfirm = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create a password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorText!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(null);
                  },
                  child: const Text('Back'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final passwordValue = passwordController.text;
                    final confirmValue = confirmController.text;

                    if (passwordValue.length < 8) {
                      setState(() {
                        errorText = 'Password must be at least 8 characters.';
                      });
                      return;
                    }

                    if (passwordValue != confirmValue) {
                      setState(() {
                        errorText = 'Passwords do not match.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(passwordValue);
                  },
                  child: const Text('Finish'),
                ),
              ],
            );
          },
        );
      },
    );

    if (password == null) {
      return null;
    }

    return _GoogleSignupInfo(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMediumScreen = screenHeight < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6E8),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: isMediumScreen ? 15 : 24),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo1.png',
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'BloomCycle',
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        'Track your cycle with confidence',
                        style: TextStyle(
                          fontSize: screenWidth > 600 ? 12 : 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // White Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(isMediumScreen ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Create Account Title
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Join thousands of women taking control of their health',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      // First Name
                      const Text(
                        'First Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your first name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Last Name
                      const Text(
                        'Last Name',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your last name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Email Address
                      const Text(
                        'Email Address',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Password
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Must be at least 8 characters long',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      // Confirm Password
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFD946A6),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Terms & Conditions Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFFD946A6),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'I agree to the ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD946A6),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _showTermsDialog(context);
                                      },
                                  ),
                                  const TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD946A6),
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _showPrivacyDialog(context);
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isCreatingAccount
                              ? null
                              : () async {
                                  if (_firstNameController.text.isEmpty ||
                                      _emailController.text.isEmpty ||
                                      _passwordController.text.isEmpty ||
                                      _confirmPasswordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please fill in all required fields.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_passwordController.text !=
                                      _confirmPasswordController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Passwords do not match.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (!_agreeToTerms) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please agree to the terms to continue.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isCreatingAccount = true;
                                  });

                                  try {
                                    final userCredential = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );

                                    final user = userCredential.user;

                                    if (user != null) {
                                      final firstName = _firstNameController
                                          .text
                                          .trim();
                                      final lastName = _lastNameController.text
                                          .trim();

                                      await user.updateDisplayName(
                                        '$firstName $lastName'.trim(),
                                      );

                                      await FirebaseService.createUser(
                                        user.uid,
                                        {
                                          'profile': {
                                            'firstName': firstName,
                                            'lastName': lastName,
                                            'displayName':
                                                '$firstName $lastName'.trim(),
                                            'email': user.email,
                                          },
                                          'onboarding': {
                                            'completed': false,
                                            'startedAt': DateTime.now(),
                                          },
                                        },
                                      );

                                      await user.sendEmailVerification();
                                    }

                                    if (!mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Account created! Please verify your email before signing in.',
                                        ),
                                      ),
                                    );

                                    await FirebaseAuth.instance.signOut();

                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    String errorMessage = 'Registration failed';
                                    if (e.code == 'weak-password') {
                                      errorMessage = 'Password is too weak.';
                                    } else if (e.code ==
                                        'email-already-in-use') {
                                      errorMessage =
                                          'Email is already registered.';
                                    } else if (e.code == 'invalid-email') {
                                      errorMessage = 'Invalid email address.';
                                    } else {
                                      errorMessage =
                                          e.message ?? 'Registration failed';
                                    }

                                    if (mounted) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(errorMessage)),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isCreatingAccount = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD946A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isCreatingAccount
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Social Signup Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _isGoogleLoading
                                    ? null
                                    : _signUpWithGoogle,
                                child: Center(
                                  child: _isGoogleLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Color(0xFF4285F4),
                                                ),
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/google.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Facebook Button
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1877F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Handle Facebook signup
                                },
                                child: const Icon(
                                  Icons.facebook,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Sign In Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign in',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFD946A6),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginPage(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignupInfo {
  const _GoogleSignupInfo({required this.email, required this.password});

  final String email;
  final String password;
}
