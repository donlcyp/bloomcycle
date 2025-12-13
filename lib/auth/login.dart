import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import '../views/nav/nav.dart';
import '../views/admin/admin_dashboard.dart';
import '../services/firebase_service.dart';
import '../services/google_sign_in_helper.dart';
import '../views/setup/step1.dart';
import '../state/user_state.dart';
import '../models/profile_model.dart';
import '../models/user_profile_data.dart';
import '../main.dart';

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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoggingIn = false;
  bool _isFacebookLoading = false;
  bool _isGoogleLoading = false;

  Future<void> _handlePostSignIn(User? user, {required String source}) async {
    if (user == null) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Authentication failed. Try again.')),
      );
      return;
    }

    final providerData = user.providerData.isNotEmpty
        ? user.providerData.first
        : null;

    final profileData = {
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'phoneNumber': user.phoneNumber,
      'provider': source,
      'providerId': providerData?.providerId,
    };

    bool permissionDenied = false;

    try {
      await FirebaseService.createUser(user.uid, {
        'profile': profileData,
        'lastSignInAt': DateTime.now(),
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      permissionDenied = e.code == 'permission-denied';
      final message = permissionDenied
          ? 'We could not sync your profile because Firestore security rules blocked the write. Make sure authenticated users can read/write their own users/{uid} document.'
          : e.message ?? 'Failed to sync your profile.';
      appScaffoldMessengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Failed to sync your profile: $e')),
      );
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Unable to complete sign-in. Please try again.'),
        ),
      );
      return;
    }

    if (!refreshedUser.emailVerified) {
      await refreshedUser.sendEmailVerification();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please verify your email. A verification link has been sent.',
          ),
        ),
      );

      await FirebaseAuth.instance.signOut();
      return;
    }

    Map<String, dynamic>? userRecord;
    try {
      userRecord = await FirebaseService.getUser(refreshedUser.uid);
    } on FirebaseException catch (e) {
      permissionDenied = permissionDenied || e.code == 'permission-denied';
      if (mounted) {
        final message = permissionDenied
            ? 'Unable to load your profile because Firestore security rules blocked the read.'
            : e.message ?? 'Unable to load your profile.';
        appScaffoldMessengerKey.currentState
            ?.showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Unable to load your profile: $e')),
        );
      }
    }

    final onboardingData =
        (userRecord?['onboarding'] as Map<String, dynamic>?) ?? {};
    final bool onboardingComplete = permissionDenied
        ? true
        : onboardingData['completed'] == true;

    if (!mounted) return;

    final destination = onboardingComplete
        ? const NavBar()
        : const SetupStep1();

    final profile = _toProfileModel(refreshedUser, userRecord);
    UserState.currentUser = UserProfileData(
      profile: profile,
      healthData: UserState.currentUser.healthData,
      settings: UserState.currentUser.settings,
      privacy: UserState.currentUser.privacy,
    );

    if (!context.mounted) return;
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (route) => false,
    );
  }

  ProfileModel _toProfileModel(User user, Map<String, dynamic>? userRecord) {
    final profileMap = (userRecord?['profile'] as Map<String, dynamic>?) ?? {};
    final displayName = (profileMap['displayName'] as String?) ?? user.displayName ?? '';
    final parts = displayName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final email = (profileMap['email'] as String?) ?? user.email ?? '';
    final phone = (profileMap['phoneNumber'] as String?) ?? user.phoneNumber ?? '';
    final photoURL = (profileMap['photoURL'] as String?) ?? user.photoURL ?? '';
    final createdAt = (userRecord?['createdAt'] as DateTime?) ??
        user.metadata.creationTime ??
        DateTime.now();
    final cycleLength = (userRecord?['profile']?['cycleLength'] as int?) ?? 28;
    final location = (userRecord?['profile']?['location'] as String?) ?? '';
    final bio = (userRecord?['profile']?['bio'] as String?) ?? '';

    return ProfileModel(
      id: user.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
      location: location,
      bio: bio,
      avatarUrl: photoURL,
      memberSince: createdAt,
      cycleLength: cycleLength,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final result = await signInWithGoogleCredential();

      if (result == null) {
        if (!mounted) return;
        appScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled.')),
        );
        return;
      }

      await _handlePostSignIn(result.userCredential.user, source: 'google');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(e.message ?? 'Google sign-in failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState
          ?.showSnackBar(SnackBar(content: Text('Google sign-in error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: const ['email', 'public_profile'],
      );

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken? accessToken = result.accessToken;
          if (accessToken == null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facebook login token missing.')),
            );
            break;
          }

          final OAuthCredential credential = FacebookAuthProvider.credential(
            accessToken.tokenString,
          );

          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          await _handlePostSignIn(userCredential.user, source: 'facebook');
          break;
        case LoginStatus.cancelled:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facebook login cancelled.')),
          );
          break;
        case LoginStatus.failed:
          final message = result.message ?? 'Facebook login failed.';
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          break;
        case LoginStatus.operationInProgress:
          break;
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Facebook login failed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Facebook login error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
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
                // Logo and App Name Header
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
                      // Sign In Title
                      const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome back! Please log in to your account',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
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
                          hintText: 'Enter your password',
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
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
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
                      const SizedBox(height: 12),
                      // Remember Me and Forgot Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFFD946A6),
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle forgot password
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFD946A6),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoggingIn
                              ? null
                              : () async {
                                  if (_emailController.text.isEmpty ||
                                      _passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please enter both email and password.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoggingIn = true;
                                  });

                                  try {
                                    // Check for placeholder admin account
                                    if (_emailController.text.trim() ==
                                            'admin@bloomcycle.com' &&
                                        _passwordController.text ==
                                            'admin123') {
                                      if (!mounted) return;

                                      // ignore: use_build_context_synchronously
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminDashboard(),
                                        ),
                                        (route) => false,
                                      );
                                      return;
                                    }

                                    // Sign in with Firebase
                                    final credential = await FirebaseAuth
                                        .instance
                                        .signInWithEmailAndPassword(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );

                                    await _handlePostSignIn(
                                      credential.user,
                                      source: 'email',
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    String errorMessage = 'Login failed';
                                    if (e.code == 'user-not-found') {
                                      errorMessage =
                                          'No account found with this email.';
                                    } else if (e.code == 'wrong-password') {
                                      errorMessage = 'Incorrect password.';
                                    } else if (e.code == 'invalid-email') {
                                      errorMessage = 'Invalid email address.';
                                    } else if (e.code == 'user-disabled') {
                                      errorMessage =
                                          'This account has been disabled.';
                                    } else {
                                      errorMessage =
                                          e.message ?? 'Login failed';
                                    }

                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoggingIn = false;
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
                          child: _isLoggingIn
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
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Already have account? Sign up
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: 'Sign up',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFD946A6),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Social Login
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
                                    : () {
                                        _signInWithGoogle();
                                      },
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
                                onTap: _isFacebookLoading
                                    ? null
                                    : () {
                                        _signInWithFacebook();
                                      },
                                child: Center(
                                  child: _isFacebookLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.facebook,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Terms of Service and Privacy Policy
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'By signing in, you agree to our\n',
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: const TextStyle(
                            fontSize: 10,
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
                          style: TextStyle(fontSize: 10, color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            fontSize: 10,
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
          ),
        ),
      ),
    );
  }
}
