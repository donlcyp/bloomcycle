import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/firebase_service.dart';
import '../../models/settings_model.dart';
import 'healthdata.dart';
import 'settings.dart';
import 'privacy.dart';
import '../../auth/login.dart';
import '../../state/user_state.dart';
import '../../services/cloudinary_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUploading = false;
  bool _isLocationUpdating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProfile();
  }

  Future<void> _updateLocationFromDevice() async {
    if (_isLocationUpdating) return;

    setState(() {
      _isLocationUpdating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is permanently denied. Please enable it in Settings.',
            ),
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final parts = <String>[];
      final locality = (place?.locality ?? '').trim();
      final admin = (place?.administrativeArea ?? '').trim();
      final country = (place?.country ?? '').trim();
      if (locality.isNotEmpty) parts.add(locality);
      if (admin.isNotEmpty && admin != locality) parts.add(admin);
      if (country.isNotEmpty) parts.add(country);

      final formatted = parts.isEmpty
          ? '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
          : parts.join(', ');

      final uid = UserState.currentUser.profile.id;
      final updated = UserState.currentUser.profile.copyWith(
        location: formatted,
      );
      UserState.currentUser = UserState.currentUser.copyWith(profile: updated);
      await FirebaseService.updateUser(uid, {
        'profile': {'location': formatted},
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Location updated: $formatted')));
      setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to fetch your location.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocationUpdating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    await FirebaseService.initialize();
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid.isNotEmpty == true
        ? authUser!.uid
        : UserState.currentUser.profile.id;
    final data = await FirebaseService.getUser(uid);
    if (!mounted) return;
    if (data != null) {
      final profileJson = Map<String, dynamic>.from(data['profile'] ?? {});
      profileJson['id'] = uid;
      final ms = profileJson['memberSince'];
      if (ms is DateTime) {
        profileJson['memberSince'] = ms.toIso8601String();
      }
      final payload = {
        'profile': profileJson,
        'healthData': Map<String, dynamic>.from(data['healthData'] ?? {}),
        'settings': Map<String, dynamic>.from(data['settings'] ?? {}),
        'privacy': Map<String, dynamic>.from(data['privacy'] ?? {}),
      };
      UserState.currentUser = UserState.currentUser.copyWith(
        profile: UserState.currentUser.profile.copyWith(
          id: uid,
          firstName:
              profileJson['firstName'] ??
              UserState.currentUser.profile.firstName,
          lastName:
              profileJson['lastName'] ?? UserState.currentUser.profile.lastName,
          email: profileJson['email'] ?? UserState.currentUser.profile.email,
          phoneNumber:
              profileJson['phoneNumber'] ??
              UserState.currentUser.profile.phoneNumber,
          location:
              profileJson['location'] ?? UserState.currentUser.profile.location,
          bio: profileJson['bio'] ?? UserState.currentUser.profile.bio,
          avatarUrl:
              profileJson['avatarUrl'] ??
              UserState.currentUser.profile.avatarUrl,
          memberSince:
              DateTime.tryParse(
                profileJson['memberSince'] ?? DateTime.now().toIso8601String(),
              ) ??
              UserState.currentUser.profile.memberSince,
          cycleLength:
              profileJson['cycleLength'] ??
              UserState.currentUser.profile.cycleLength,
        ),
        settings: SettingsModel.fromJson(
          payload['settings'] as Map<String, dynamic>,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Pink Header Section
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE91E63), Color(0xFFD946A6)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Profile Avatar
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (picked == null) return;
                        if (!mounted) return;
                        setState(() {
                          _isUploading = true;
                        });
                        final bytes = await picked.readAsBytes();
                        final service = CloudinaryService();
                        final url = await service.uploadImageBytes(
                          bytes,
                          filename: picked.name,
                        );
                        if (url != null && url.isNotEmpty) {
                          final updatedProfile = UserState.currentUser.profile
                              .copyWith(avatarUrl: url);
                          UserState.currentUser = UserState.currentUser
                              .copyWith(profile: updatedProfile);
                          final uid = UserState.currentUser.profile.id;
                          await FirebaseService.updateUser(uid, {
                            'profile': {'avatarUrl': url},
                          });
                          if (mounted) {
                            setState(() {});
                          }
                        }
                        if (mounted) {
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Builder(
                              builder: (context) {
                                final avatarUrl =
                                    UserState.currentUser.profile.avatarUrl;
                                if (avatarUrl.isNotEmpty) {
                                  return ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return const Center(
                                              child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Color(0xFFD946A6)),
                                                ),
                                              ),
                                            );
                                          },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            final initials = UserState
                                                .currentUser
                                                .profile
                                                .initials;
                                            return Center(
                                              child: Text(
                                                initials.isNotEmpty
                                                    ? initials
                                                    : 'JD',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFFD946A6),
                                                ),
                                              ),
                                            );
                                          },
                                    ),
                                  );
                                }
                                final initials =
                                    UserState.currentUser.profile.initials;
                                return Center(
                                  child: Text(
                                    initials.isNotEmpty ? initials : 'JD',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD946A6),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[600],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          if (_isUploading)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFD946A6),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      UserState.currentUser.profile.fullName.isNotEmpty
                          ? UserState.currentUser.profile.fullName
                          : '—',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Bio
                    Text(
                      UserState.currentUser.profile.bio.isNotEmpty
                          ? UserState.currentUser.profile.bio
                          : '—',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Location
                    Text(
                      UserState.currentUser.profile.location.isNotEmpty
                          ? UserState.currentUser.profile.location
                          : '—',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Member Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Member since',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${UserState.currentUser.profile.memberSince.month == 1
                                  ? 'January'
                                  : UserState.currentUser.profile.memberSince.month == 2
                                  ? 'February'
                                  : UserState.currentUser.profile.memberSince.month == 3
                                  ? 'March'
                                  : UserState.currentUser.profile.memberSince.month == 4
                                  ? 'April'
                                  : UserState.currentUser.profile.memberSince.month == 5
                                  ? 'May'
                                  : UserState.currentUser.profile.memberSince.month == 6
                                  ? 'June'
                                  : UserState.currentUser.profile.memberSince.month == 7
                                  ? 'July'
                                  : UserState.currentUser.profile.memberSince.month == 8
                                  ? 'August'
                                  : UserState.currentUser.profile.memberSince.month == 9
                                  ? 'September'
                                  : UserState.currentUser.profile.memberSince.month == 10
                                  ? 'October'
                                  : UserState.currentUser.profile.memberSince.month == 11
                                  ? 'November'
                                  : 'December'} ${UserState.currentUser.profile.memberSince.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text(
                              'Cycle Length',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${UserState.currentUser.profile.cycleLength} days',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Basic logout: clear in-memory user state and go to login
                          UserState.dateOfBirth = null;
                          UserState.weightKg = null;

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Log out'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFD946A6),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFD946A6),
              indicatorWeight: 2,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              tabs: const [
                Tab(text: 'Personal Info'),
                Tab(text: 'Health Data'),
                Tab(text: 'Settings'),
                Tab(text: 'Privacy'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(),
                _buildHealthDataTab(),
                _buildSettingsTab(),
                _buildPrivacyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoField('Full Name', UserState.currentUser.profile.fullName),
          const SizedBox(height: 20),
          _buildInfoField('Email Address', UserState.currentUser.profile.email),
          const SizedBox(height: 20),
          _buildInfoField(
            'Phone Number',
            UserState.currentUser.profile.phoneNumber.isNotEmpty
                ? UserState.currentUser.profile.phoneNumber
                : '—',
          ),
          const SizedBox(height: 20),
          _buildInfoField(
            'Location',
            UserState.currentUser.profile.location.isNotEmpty
                ? UserState.currentUser.profile.location
                : '—',
          ),
          const SizedBox(height: 32),
          const Text(
            'About',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _buildBioField(),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              GestureDetector(
                onTap: () async {
                  if (label == 'Location') {
                    await _updateLocationFromDevice();
                    setState(() {});
                    return;
                  }
                  final newValue = await _promptTextEdit(
                    title: 'Edit $label',
                    initial: value == '—' ? '' : value,
                    maxLines: 1,
                  );
                  if (newValue == null) return;
                  final uid = UserState.currentUser.profile.id;
                  if (label == 'Full Name') {
                    final parts = newValue.trim().split(RegExp(r'\\s+'));
                    final first = parts.isNotEmpty ? parts.first : '';
                    final last = parts.length > 1
                        ? parts.sublist(1).join(' ')
                        : '';
                    final updated = UserState.currentUser.profile.copyWith(
                      firstName: first,
                      lastName: last,
                    );
                    UserState.currentUser = UserState.currentUser.copyWith(
                      profile: updated,
                    );
                    await FirebaseService.updateUser(uid, {
                      'profile': {'firstName': first, 'lastName': last},
                    });
                  } else if (label == 'Email Address') {
                    final updated = UserState.currentUser.profile.copyWith(
                      email: newValue.trim(),
                    );
                    UserState.currentUser = UserState.currentUser.copyWith(
                      profile: updated,
                    );
                    await FirebaseService.updateUser(uid, {
                      'profile': {'email': newValue.trim()},
                    });
                  } else if (label == 'Phone Number') {
                    final updated = UserState.currentUser.profile.copyWith(
                      phoneNumber: newValue.trim(),
                    );
                    UserState.currentUser = UserState.currentUser.copyWith(
                      profile: updated,
                    );
                    await FirebaseService.updateUser(uid, {
                      'profile': {'phoneNumber': newValue.trim()},
                    });
                  }
                  setState(() {});
                },
                child: Text(
                  label == 'Location'
                      ? (_isLocationUpdating ? 'Using…' : 'Use')
                      : 'Edit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD946A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UserState.currentUser.profile.bio.isNotEmpty
                    ? UserState.currentUser.profile.bio
                    : '—',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final initial = UserState.currentUser.profile.bio;
                  final newValue = await _promptTextEdit(
                    title: 'Edit Bio',
                    initial: initial,
                    maxLines: 5,
                  );
                  if (newValue == null) return;
                  final uid = UserState.currentUser.profile.id;
                  final updated = UserState.currentUser.profile.copyWith(
                    bio: newValue.trim(),
                  );
                  UserState.currentUser = UserState.currentUser.copyWith(
                    profile: updated,
                  );
                  await FirebaseService.updateUser(uid, {
                    'profile': {'bio': newValue.trim()},
                  });
                  setState(() {});
                },
                child: const Text(
                  'Edit Bio',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD946A6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> _promptTextEdit({
    required String title,
    required String initial,
    int maxLines = 1,
  }) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: const InputDecoration(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHealthDataTab() {
    return const HealthDataPage();
  }

  Widget _buildSettingsTab() {
    return const SettingsPage();
  }

  Widget _buildPrivacyTab() {
    return const PrivacyPage();
  }
}
