class NotificationPreference {
  final String id;
  final String type;
  final bool enabled;
  final String title;
  final String description;
  final int daysBeforeEvent;
  final String frequency;

  NotificationPreference({
    required this.id,
    required this.type,
    required this.enabled,
    required this.title,
    required this.description,
    required this.daysBeforeEvent,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'enabled': enabled,
      'title': title,
      'description': description,
      'daysBeforeEvent': daysBeforeEvent,
      'frequency': frequency,
    };
  }

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      enabled: json['enabled'] ?? true,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      daysBeforeEvent: json['daysBeforeEvent'] ?? 0,
      frequency: json['frequency'] ?? 'once',
    );
  }

  NotificationPreference copyWith({
    String? id,
    String? type,
    bool? enabled,
    String? title,
    String? description,
    int? daysBeforeEvent,
    String? frequency,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      type: type ?? this.type,
      enabled: enabled ?? this.enabled,
      title: title ?? this.title,
      description: description ?? this.description,
      daysBeforeEvent: daysBeforeEvent ?? this.daysBeforeEvent,
      frequency: frequency ?? this.frequency,
    );
  }
}

class PushNotificationSettings {
  final List<NotificationPreference> preferences;
  final bool globalEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  PushNotificationSettings({
    required this.preferences,
    required this.globalEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'preferences': preferences.map((p) => p.toJson()).toList(),
      'globalEnabled': globalEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }

  factory PushNotificationSettings.fromJson(Map<String, dynamic> json) {
    return PushNotificationSettings(
      preferences: ((json['preferences'] as List?) ?? [])
          .map(
            (p) => NotificationPreference.fromJson(p as Map<String, dynamic>),
          )
          .toList(),
      globalEnabled: json['globalEnabled'] ?? true,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '08:00',
    );
  }

  static PushNotificationSettings get defaultSettings {
    return PushNotificationSettings(
      preferences: [
        NotificationPreference(
          id: 'period_prediction',
          type: 'period',
          enabled: true,
          title: 'Period Starting Soon',
          description: 'Your period is expected in the next few days',
          daysBeforeEvent: 2,
          frequency: 'once',
        ),
        NotificationPreference(
          id: 'fertile_window',
          type: 'fertile',
          enabled: true,
          title: 'Fertile Window',
          description: 'You\'re in your fertile window',
          daysBeforeEvent: 0,
          frequency: 'daily',
        ),
        NotificationPreference(
          id: 'ovulation',
          type: 'ovulation',
          enabled: true,
          title: 'Ovulation Day',
          description: 'Today is your predicted ovulation day',
          daysBeforeEvent: 0,
          frequency: 'once',
        ),
        NotificationPreference(
          id: 'logging_reminder',
          type: 'logging',
          enabled: true,
          title: 'Log Your Symptoms',
          description: 'Don\'t forget to log your symptoms today',
          daysBeforeEvent: 0,
          frequency: 'daily',
        ),
      ],
      globalEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
    );
  }

  PushNotificationSettings copyWith({
    List<NotificationPreference>? preferences,
    bool? globalEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return PushNotificationSettings(
      preferences: preferences ?? this.preferences,
      globalEnabled: globalEnabled ?? this.globalEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
