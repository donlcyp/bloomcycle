class PrivacyModel {
  final SecuritySettings securitySettings;
  final DataManagement dataManagement;
  final AccountSettings accountSettings;

  PrivacyModel({
    required this.securitySettings,
    required this.dataManagement,
    required this.accountSettings,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'securitySettings': securitySettings.toJson(),
      'dataManagement': dataManagement.toJson(),
      'accountSettings': accountSettings.toJson(),
    };
  }

  // Create from JSON
  factory PrivacyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyModel(
      securitySettings: SecuritySettings.fromJson(json['securitySettings'] ?? {}),
      dataManagement: DataManagement.fromJson(json['dataManagement'] ?? {}),
      accountSettings: AccountSettings.fromJson(json['accountSettings'] ?? {}),
    );
  }

  // Create a copy with updated fields
  PrivacyModel copyWith({
    SecuritySettings? securitySettings,
    DataManagement? dataManagement,
    AccountSettings? accountSettings,
  }) {
    return PrivacyModel(
      securitySettings: securitySettings ?? this.securitySettings,
      dataManagement: dataManagement ?? this.dataManagement,
      accountSettings: accountSettings ?? this.accountSettings,
    );
  }

  // Default privacy settings for testing/placeholder
  static PrivacyModel get defaultPrivacy => PrivacyModel(
    securitySettings: SecuritySettings.defaultSettings,
    dataManagement: DataManagement.defaultSettings,
    accountSettings: AccountSettings.defaultSettings,
  );
}

class SecuritySettings {
  final bool twoFactorAuthEnabled;
  final DateTime? lastPasswordChange;
  final List<String> activeSessions;

  SecuritySettings({
    required this.twoFactorAuthEnabled,
    this.lastPasswordChange,
    required this.activeSessions,
  });

  Map<String, dynamic> toJson() {
    return {
      'twoFactorAuthEnabled': twoFactorAuthEnabled,
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'activeSessions': activeSessions,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      twoFactorAuthEnabled: json['twoFactorAuthEnabled'] ?? false,
      lastPasswordChange: json['lastPasswordChange'] != null 
          ? DateTime.parse(json['lastPasswordChange']) 
          : null,
      activeSessions: List<String>.from(json['activeSessions'] ?? []),
    );
  }

  SecuritySettings copyWith({
    bool? twoFactorAuthEnabled,
    DateTime? lastPasswordChange,
    List<String>? activeSessions,
  }) {
    return SecuritySettings(
      twoFactorAuthEnabled: twoFactorAuthEnabled ?? this.twoFactorAuthEnabled,
      lastPasswordChange: lastPasswordChange ?? this.lastPasswordChange,
      activeSessions: activeSessions ?? this.activeSessions,
    );
  }

  static SecuritySettings get defaultSettings => SecuritySettings(
    twoFactorAuthEnabled: false,
    lastPasswordChange: DateTime.now().subtract(const Duration(days: 30)),
    activeSessions: ['Current Session'],
  );
}

class DataManagement {
  final bool dataExportAvailable;
  final DateTime? lastDataExport;
  final int totalDataSize; // in MB
  final List<String> dataCategories;

  DataManagement({
    required this.dataExportAvailable,
    this.lastDataExport,
    required this.totalDataSize,
    required this.dataCategories,
  });

  Map<String, dynamic> toJson() {
    return {
      'dataExportAvailable': dataExportAvailable,
      'lastDataExport': lastDataExport?.toIso8601String(),
      'totalDataSize': totalDataSize,
      'dataCategories': dataCategories,
    };
  }

  factory DataManagement.fromJson(Map<String, dynamic> json) {
    return DataManagement(
      dataExportAvailable: json['dataExportAvailable'] ?? true,
      lastDataExport: json['lastDataExport'] != null 
          ? DateTime.parse(json['lastDataExport']) 
          : null,
      totalDataSize: json['totalDataSize'] ?? 0,
      dataCategories: List<String>.from(json['dataCategories'] ?? []),
    );
  }

  DataManagement copyWith({
    bool? dataExportAvailable,
    DateTime? lastDataExport,
    int? totalDataSize,
    List<String>? dataCategories,
  }) {
    return DataManagement(
      dataExportAvailable: dataExportAvailable ?? this.dataExportAvailable,
      lastDataExport: lastDataExport ?? this.lastDataExport,
      totalDataSize: totalDataSize ?? this.totalDataSize,
      dataCategories: dataCategories ?? this.dataCategories,
    );
  }

  static DataManagement get defaultSettings => DataManagement(
    dataExportAvailable: true,
    lastDataExport: null,
    totalDataSize: 15, // 15 MB
    dataCategories: [
      'Profile Information',
      'Cycle Data',
      'Health Metrics',
      'Mood Entries',
      'Symptoms',
      'Settings'
    ],
  );
}

class AccountSettings {
  final bool accountDeletionRequested;
  final DateTime? deletionScheduledDate;
  final String accountStatus;

  AccountSettings({
    required this.accountDeletionRequested,
    this.deletionScheduledDate,
    required this.accountStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'accountDeletionRequested': accountDeletionRequested,
      'deletionScheduledDate': deletionScheduledDate?.toIso8601String(),
      'accountStatus': accountStatus,
    };
  }

  factory AccountSettings.fromJson(Map<String, dynamic> json) {
    return AccountSettings(
      accountDeletionRequested: json['accountDeletionRequested'] ?? false,
      deletionScheduledDate: json['deletionScheduledDate'] != null 
          ? DateTime.parse(json['deletionScheduledDate']) 
          : null,
      accountStatus: json['accountStatus'] ?? 'active',
    );
  }

  AccountSettings copyWith({
    bool? accountDeletionRequested,
    DateTime? deletionScheduledDate,
    String? accountStatus,
  }) {
    return AccountSettings(
      accountDeletionRequested: accountDeletionRequested ?? this.accountDeletionRequested,
      deletionScheduledDate: deletionScheduledDate ?? this.deletionScheduledDate,
      accountStatus: accountStatus ?? this.accountStatus,
    );
  }

  static AccountSettings get defaultSettings => AccountSettings(
    accountDeletionRequested: false,
    deletionScheduledDate: null,
    accountStatus: 'active',
  );

  // Account status options
  static List<String> get availableStatuses => [
    'active',
    'suspended',
    'pending_deletion',
    'deactivated',
  ];
}
