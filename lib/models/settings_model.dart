class SettingsModel {
  final NotificationSettings notificationSettings;
  final AppPreferences appPreferences;

  SettingsModel({
    required this.notificationSettings,
    required this.appPreferences,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'notificationSettings': notificationSettings.toJson(),
      'appPreferences': appPreferences.toJson(),
    };
  }

  // Create from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings'] ?? {}),
      appPreferences: AppPreferences.fromJson(json['appPreferences'] ?? {}),
    );
  }

  // Create a copy with updated fields
  SettingsModel copyWith({
    NotificationSettings? notificationSettings,
    AppPreferences? appPreferences,
  }) {
    return SettingsModel(
      notificationSettings: notificationSettings ?? this.notificationSettings,
      appPreferences: appPreferences ?? this.appPreferences,
    );
  }

  // Default settings for testing/placeholder
  static SettingsModel get defaultSettings => SettingsModel(
    notificationSettings: NotificationSettings.defaultSettings,
    appPreferences: AppPreferences.defaultPreferences,
  );
}

class NotificationSettings {
  final bool allNotifications;
  final bool emailNotifications;
  final bool pushNotifications;

  NotificationSettings({
    required this.allNotifications,
    required this.emailNotifications,
    required this.pushNotifications,
  });

  Map<String, dynamic> toJson() {
    return {
      'allNotifications': allNotifications,
      'emailNotifications': emailNotifications,
      'pushNotifications': pushNotifications,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      allNotifications: json['allNotifications'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? false,
    );
  }

  NotificationSettings copyWith({
    bool? allNotifications,
    bool? emailNotifications,
    bool? pushNotifications,
  }) {
    return NotificationSettings(
      allNotifications: allNotifications ?? this.allNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
    );
  }

  static NotificationSettings get defaultSettings => NotificationSettings(
    allNotifications: true,
    emailNotifications: true,
    pushNotifications: false,
  );
}

class AppPreferences {
  final bool darkMode;
  final String language;
  final String timeZone;

  AppPreferences({
    required this.darkMode,
    required this.language,
    required this.timeZone,
  });

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode,
      'language': language,
      'timeZone': timeZone,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      darkMode: json['darkMode'] ?? false,
      language: json['language'] ?? 'English (US)',
      timeZone: json['timeZone'] ?? 'Pacific Time (PT)',
    );
  }

  AppPreferences copyWith({
    bool? darkMode,
    String? language,
    String? timeZone,
  }) {
    return AppPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      timeZone: timeZone ?? this.timeZone,
    );
  }

  static AppPreferences get defaultPreferences => AppPreferences(
    darkMode: false,
    language: 'English (US)',
    timeZone: 'Pacific Time (PT)',
  );

  // Available options
  static List<String> get availableLanguages => [
    'English (US)',
    'English (UK)',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
  ];

  static List<String> get availableTimeZones => [
    'Pacific Time (PT)',
    'Mountain Time (MT)',
    'Central Time (CT)',
    'Eastern Time (ET)',
    'GMT',
    'CET',
    'JST',
  ];
}
