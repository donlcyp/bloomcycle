import 'package:flutter/material.dart';
import '../../state/user_state.dart';
import '../../services/firebase_service.dart';
import '../../models/settings_model.dart';
import '../settings/notifications_settings.dart';
import '../health/health_goals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _allNotifications = true;
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _darkMode = false;
  String _selectedLanguage = 'English (US)';
  String _selectedTimeZone = 'Pacific Time (PT)';
  int _cycleLength = 28;
  int _periodLength = 5;

  @override
  void initState() {
    super.initState();
    final s = UserState.currentUser.settings;
    _allNotifications = s.notificationSettings.allNotifications;
    _emailNotifications = s.notificationSettings.emailNotifications;
    _pushNotifications = s.notificationSettings.pushNotifications;
    _darkMode = s.appPreferences.darkMode;
    _selectedLanguage = s.appPreferences.language;
    _selectedTimeZone = s.appPreferences.timeZone;
    _cycleLength = s.cycleSettings.cycleLength;
    _periodLength = s.cycleSettings.periodLength;
  }

  Future<void> _persistSettings(SettingsModel updated) async {
    final uid = UserState.currentUser.profile.id;
    UserState.currentUser = UserState.currentUser.copyWith(settings: updated);
    await FirebaseService.updateUser(uid, {
      'settings': updated.toJson(),
      'profile': {
        // keep profile.cycleLength in sync with settings cycle length
        'cycleLength': updated.cycleSettings.cycleLength,
      },
    });
  }

  final List<String> _languages = [
    'English (US)',
    'English (UK)',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];

  final List<String> _timeZones = [
    'Pacific Time (PT)',
    'Mountain Time (MT)',
    'Central Time (CT)',
    'Eastern Time (ET)',
    'GMT',
    'CET',
    'JST',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSettings(),
            const SizedBox(height: 32),
            _buildCycleSettings(),
            const SizedBox(height: 32),
            _buildAppPreferences(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationsSettingsPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946A6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: Color(0xFFD946A6)),
                    SizedBox(width: 4),
                    Text(
                      'Advanced',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD946A6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildToggleItem(
          'All Notifications',
          'Enable or disable all notifications',
          _allNotifications,
          (value) {
            setState(() {
              _allNotifications = value;
              if (!value) {
                _emailNotifications = false;
                _pushNotifications = false;
              }
            });
            final updated = UserState.currentUser.settings.copyWith(
              notificationSettings: UserState
                  .currentUser
                  .settings
                  .notificationSettings
                  .copyWith(
                    allNotifications: _allNotifications,
                    emailNotifications: _emailNotifications,
                    pushNotifications: _pushNotifications,
                  ),
            );
            _persistSettings(updated);
          },
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          'Email Notifications',
          'Receive updates via email',
          _emailNotifications,
          (value) {
            setState(() {
              _emailNotifications = value;
              if (value && !_allNotifications) {
                _allNotifications = true;
              }
            });
            final updated = UserState.currentUser.settings.copyWith(
              notificationSettings: UserState
                  .currentUser
                  .settings
                  .notificationSettings
                  .copyWith(
                    allNotifications: _allNotifications,
                    emailNotifications: _emailNotifications,
                  ),
            );
            _persistSettings(updated);
          },
        ),
        const SizedBox(height: 16),
        _buildToggleItem(
          'Push Notifications',
          'Receive push notifications on your device',
          _pushNotifications,
          (value) {
            setState(() {
              _pushNotifications = value;
              if (value && !_allNotifications) {
                _allNotifications = true;
              }
            });
            final updated = UserState.currentUser.settings.copyWith(
              notificationSettings: UserState
                  .currentUser
                  .settings
                  .notificationSettings
                  .copyWith(
                    allNotifications: _allNotifications,
                    pushNotifications: _pushNotifications,
                  ),
            );
            _persistSettings(updated);
          },
        ),
      ],
    );
  }

  Widget _buildCycleSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cycle Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        _buildSliderItem(
          'Cycle Length',
          'Average cycle length in days',
          _cycleLength.toDouble(),
          21,
          40,
          (value) {
            setState(() {
              _cycleLength = value.toInt();
            });
            final updated = UserState.currentUser.settings.copyWith(
              cycleSettings: UserState.currentUser.settings.cycleSettings
                  .copyWith(cycleLength: _cycleLength),
            );
            _persistSettings(updated);
          },
        ),
        const SizedBox(height: 20),
        _buildSliderItem(
          'Period Length',
          'Average period length in days',
          _periodLength.toDouble(),
          1,
          7,
          (value) {
            setState(() {
              _periodLength = value.toInt();
            });
            final updated = UserState.currentUser.settings.copyWith(
              cycleSettings: UserState.currentUser.settings.cycleSettings
                  .copyWith(periodLength: _periodLength),
            );
            _persistSettings(updated);
          },
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'App Preferences',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButton(
          'Health Goals',
          'Set and track your wellness targets',
          Icons.favorite_outline,
          () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HealthGoalsPage()),
            );
          },
        ),
        const SizedBox(height: 20),
        _buildToggleItem('Dark Mode', 'Switch to dark theme', _darkMode, (
          value,
        ) {
          setState(() {
            _darkMode = value;
          });
          final updated = UserState.currentUser.settings.copyWith(
            appPreferences: UserState.currentUser.settings.appPreferences
                .copyWith(darkMode: _darkMode),
          );
          _persistSettings(updated);
        }),
        const SizedBox(height: 20),
        _buildDropdownItem('Language', _selectedLanguage, _languages, (value) {
          setState(() {
            _selectedLanguage = value!;
          });
          final updated = UserState.currentUser.settings.copyWith(
            appPreferences: UserState.currentUser.settings.appPreferences
                .copyWith(language: _selectedLanguage),
          );
          _persistSettings(updated);
        }),
        const SizedBox(height: 20),
        _buildDropdownItem('Time Zone', _selectedTimeZone, _timeZones, (value) {
          setState(() {
            _selectedTimeZone = value!;
          });
          final updated = UserState.currentUser.settings.copyWith(
            appPreferences: UserState.currentUser.settings.appPreferences
                .copyWith(timeZone: _selectedTimeZone),
          );
          _persistSettings(updated);
        }),
      ],
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFD946A6),
            activeTrackColor: const Color(0xFFD946A6).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(
    String title,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              items: options.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderItem(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946A6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.toInt()} days',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD946A6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            activeColor: const Color(0xFFD946A6),
            inactiveColor: Colors.grey[300],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD946A6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFD946A6), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
