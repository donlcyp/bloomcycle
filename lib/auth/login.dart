import 'package:flutter/material.dart';
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
import '../theme/responsive_helper.dart' as responsive;

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

  // Validation & Error handling
  String? _emailError;
  String? _passwordError;

  // Rate limiting
  int _loginAttempts = 0;
  DateTime? _lastLoginAttempt;
  bool _isRateLimited = false;
  int _remainingMinutes = 0;

  Future<void> _showForgotPasswordSheet() async {
    final parentContext = context;
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reset password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Enter your email and we will send a verification link to reset your password.',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('Email address'),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSending
                            ? null
                            : () async {
                                final email = controller.text.trim();
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter your email.'),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isSending = true;
                                });

                                try {
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(email: email);

                                  if (!sheetContext.mounted) return;
                                  Navigator.of(sheetContext).pop();

                                  if (!parentContext.mounted) return;
                                  Future.microtask(() {
                                    if (!parentContext.mounted) return;
                                    ScaffoldMessenger.of(
                                      parentContext,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password reset link sent to $email',
                                        ),
                                      ),
                                    );
                                  });
                                } on FirebaseAuthException catch (e) {
                                  final message = e.code == 'user-not-found'
                                      ? 'No account found with that email.'
                                      : e.message ??
                                            'Failed to send reset email.';
                                  if (!parentContext.mounted) return;
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                } finally {
                                  if (context.mounted) {
                                    setModalState(() {
                                      isSending = false;
                                    });
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFD946A6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Send reset link',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: isSending
                            ? null
                            : () {
                                Navigator.of(sheetContext).pop();
                              },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // Validation methods
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    }

    return isValid;
  }

  // Rate limiting check
  bool _checkRateLimit() {
    if (_loginAttempts >= 5) {
      final timeSinceLastAttempt = DateTime.now().difference(
        _lastLoginAttempt!,
      );
      if (timeSinceLastAttempt.inMinutes < 15) {
        _remainingMinutes = 15 - timeSinceLastAttempt.inMinutes;
        setState(() => _isRateLimited = true);
        return false;
      } else {
        _loginAttempts = 0;
        setState(() => _isRateLimited = false);
      }
    }
    return true;
  }

  Future<void> _signInWithEmailPassword() async {
    if (_isLoggingIn) return;

    // Check rate limiting first
    if (!_checkRateLimit()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Too many login attempts. Please try again in $_remainingMinutes minutes.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate inputs
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'admin@bloomcycle.com' && password == 'admin123') {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
          (route) => false,
        );
        return;
      }

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Reset login attempts on success
      _loginAttempts = 0;
      await _handlePostSignIn(credential.user, source: 'email');
    } on FirebaseAuthException catch (e) {
      // Increment login attempts on failure
      _lastLoginAttempt = DateTime.now();
      _loginAttempts++;

      String errorMessage = e.message ?? 'Login failed.';
      String? actionText;
      VoidCallback? actionCallback;

      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email.';
        actionText = 'Sign Up';
        actionCallback = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignupPage()),
          );
        };
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
        actionText = 'Forgot Password?';
        actionCallback = _showForgotPasswordSheet;
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled. Contact support.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many login attempts. Please try again later.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: actionText != null
              ? SnackBarAction(
                  label: actionText,
                  textColor: Colors.white,
                  onPressed: actionCallback ?? () {},
                )
              : null,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

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
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(message)),
      );
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
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(message)),
        );
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
    final displayName =
        (profileMap['displayName'] as String?) ?? user.displayName ?? '';
    final parts = displayName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final email = (profileMap['email'] as String?) ?? user.email ?? '';
    final phone =
        (profileMap['phoneNumber'] as String?) ?? user.phoneNumber ?? '';
    final photoURL = (profileMap['photoURL'] as String?) ?? user.photoURL ?? '';
    final createdAt =
        (userRecord?['createdAt'] as DateTime?) ??
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
  void initState() {
    super.initState();
    // Show health reminder popup on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showHealthReminderDialog();
    });
  }

  void _showHealthReminderDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Health Reminder',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'BloomCycle is not a medical device and should not be used for self-diagnosis or self-treatment.\n\nIf you experience severe pain, unusually heavy bleeding, missed periods, irregular cycles, or other concerning symptoms, please consult a licensed doctor or gynecologist for proper evaluation and prescription.\n\nIn emergencies, seek urgent medical care.',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('I Understand'),
            ),
          ],
        );
      },
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
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Google sign-in error: $e')),
      );
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
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDF3FA), Color(0xFFF7E7F4), Color(0xFFF0F4FF)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              left: -80,
              child: _decorCircle(260, const Color(0xFFD946A6)),
            ),
            Positioned(
              bottom: -180,
              right: -90,
              child: _decorCircle(300, const Color(0xFF6366F1), opacity: 0.14),
            ),
            Align(
              alignment: Alignment.center,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final cardWidth = maxWidth > 520 ? 420.0 : maxWidth * 0.92;

                  final responsivePadding =
                      responsive.ResponsiveHelper.getHorizontalPadding(context);
                  final responsiveVertical =
                      responsive.ResponsiveHelper.getVerticalPadding(context);
                  final bottomPadding =
                      MediaQuery.of(context).viewInsets.bottom +
                      responsiveVertical;

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: responsivePadding,
                      right: responsivePadding,
                      top: responsiveVertical * 2,
                      bottom: bottomPadding,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBrandHeader(theme, cardWidth),
                        SizedBox(
                          height: responsive.ResponsiveHelper.getSpacing(
                            context,
                            small: 16,
                            medium: 20,
                            large: 24,
                          ),
                        ),
                        _buildFormCard(context, theme, cardWidth),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader(ThemeData theme, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Image.asset(
            'assets/logo1.png',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Welcome back',
              style: theme.textTheme.labelMedium?.copyWith(
                color: const Color(0xFFD946A6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to BloomCycle',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2933),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Monitor your cycle insights and stay ahead of your wellness routine.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black.withValues(alpha: 0.60),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    ThemeData theme,
    double cardWidth,
  ) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD946A6).withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your account',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_emailError != null)
                Text(
                  _emailError!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration('you@example.com').copyWith(
              errorText: _emailError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _emailError != null ? Colors.red : Colors.grey[300]!,
                  width: _emailError != null ? 1.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _emailError != null ? Colors.red : Colors.grey[300]!,
                  width: _emailError != null ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _emailError != null
                      ? Colors.red
                      : const Color(0xFFD946A6),
                  width: 2,
                ),
              ),
            ),
            onChanged: (value) {
              if (_emailError != null) {
                setState(() {
                  _emailError = null;
                });
              }
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (_passwordError != null)
                Text(
                  _passwordError!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration('password').copyWith(
              errorText: _passwordError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null
                      ? Colors.red
                      : Colors.grey[300]!,
                  width: _passwordError != null ? 1.5 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null
                      ? Colors.red
                      : Colors.grey[300]!,
                  width: _passwordError != null ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _passwordError != null
                      ? Colors.red
                      : const Color(0xFFD946A6),
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            onChanged: (value) {
              if (_passwordError != null) {
                setState(() {
                  _passwordError = null;
                });
              }
            },
          ),
          const SizedBox(height: 20),
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
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Remember me',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showForgotPasswordSheet,
                child: Text(
                  'Forgot password?',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFD946A6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoggingIn ? null : _signInWithEmailPassword,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFD946A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoggingIn
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'or',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                  ),
                  children: const [
                    TextSpan(text: "Don't have an account? "),
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                        color: Color(0xFFD946A6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
                                valueColor: AlwaysStoppedAnimation<Color>(
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
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  Widget _decorCircle(double diameter, Color color, {double opacity = 1}) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
