import '../models/user_profile_data.dart';

/// Simple in-memory holder for the current user data.
class UserState {
  UserState._();

  static UserProfileData currentUser = UserProfileData.defaultUserData;

  static DateTime? dateOfBirth;
  static double? weightKg;
}
