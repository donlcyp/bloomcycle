import 'package:flutter/material.dart';

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
        const Text(
          'Notification Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
        _buildToggleItem('Dark Mode', 'Switch to dark theme', _darkMode, (
          value,
        ) {
          setState(() {
            _darkMode = value;
          });
        }),
        const SizedBox(height: 20),
        _buildDropdownItem('Language', _selectedLanguage, _languages, (value) {
          setState(() {
            _selectedLanguage = value!;
          });
        }),
        const SizedBox(height: 20),
        _buildDropdownItem('Time Zone', _selectedTimeZone, _timeZones, (value) {
          setState(() {
            _selectedTimeZone = value!;
          });
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
            activeTrackColor: const Color(0xFFD946A6).withOpacity(0.3),
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
              Column(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946A6).withOpacity(0.1),
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
}
