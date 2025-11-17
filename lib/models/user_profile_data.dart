import 'profile_model.dart';
import 'health_data_model.dart';
import 'settings_model.dart';
import 'privacy_model.dart';

// Combined Profile Data Model
class UserProfileData {
  final ProfileModel profile;
  final HealthDataModel healthData;
  final SettingsModel settings;
  final PrivacyModel privacy;

  UserProfileData({
    required this.profile,
    required this.healthData,
    required this.settings,
    required this.privacy,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'healthData': healthData.toJson(),
      'settings': settings.toJson(),
      'privacy': privacy.toJson(),
    };
  }

  // Create from JSON
  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      profile: ProfileModel.fromJson(json['profile'] ?? {}),
      healthData: HealthDataModel.fromJson(json['healthData'] ?? {}),
      settings: SettingsModel.fromJson(json['settings'] ?? {}),
      privacy: PrivacyModel.fromJson(json['privacy'] ?? {}),
    );
  }

  // Create a copy with updated fields
  UserProfileData copyWith({
    ProfileModel? profile,
    HealthDataModel? healthData,
    SettingsModel? settings,
    PrivacyModel? privacy,
  }) {
    return UserProfileData(
      profile: profile ?? this.profile,
      healthData: healthData ?? this.healthData,
      settings: settings ?? this.settings,
      privacy: privacy ?? this.privacy,
    );
  }

  // Default complete user profile data for testing/placeholder
  static UserProfileData get defaultUserData => UserProfileData(
    profile: ProfileModel.defaultProfile,
    healthData: HealthDataModel.defaultHealthData,
    settings: SettingsModel.defaultSettings,
    privacy: PrivacyModel.defaultPrivacy,
  );
}
