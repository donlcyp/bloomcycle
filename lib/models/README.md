# Profile Models

This folder contains all the data models for the profile-related functionality in the BloomCycle app.

## Model Files

### 1. `profile_model.dart`
Contains the main user profile information:
- **ProfileModel**: User's basic information (name, email, location, bio, etc.)
- Includes JSON serialization/deserialization
- Provides default placeholder data for Jessica Davis

### 2. `health_data_model.dart`
Contains health and cycle tracking data:
- **HealthDataModel**: Main container for all health data
- **CycleTrackingData**: Menstrual cycle information (length, dates)
- **WellnessStatsData**: Tracking statistics (days, mood entries, symptoms)
- **HealthGoalsData**: Progress tracking for water intake and exercise

### 3. `settings_model.dart`
Contains app settings and preferences:
- **SettingsModel**: Main container for all settings
- **NotificationSettings**: Notification preferences (email, push, etc.)
- **AppPreferences**: App-specific settings (dark mode, language, timezone)

### 4. `privacy_model.dart`
Contains privacy and security settings:
- **PrivacyModel**: Main container for privacy settings
- **SecuritySettings**: 2FA, password changes, active sessions
- **DataManagement**: Data export, size, categories
- **AccountSettings**: Account status and deletion settings

### 5. `profile_models.dart`
Index file that exports all models and provides:
- **UserProfileData**: Combined model containing all profile data
- Easy import access to all models via single import

## Usage

### Import all models:
```dart
import 'package:bloomcycle/models/profile_models.dart';
```

### Import specific model:
```dart
import 'package:bloomcycle/models/profile_model.dart';
```

### Use default data:
```dart
final defaultProfile = ProfileModel.defaultProfile;
final defaultHealthData = HealthDataModel.defaultHealthData;
final completeUserData = UserProfileData.defaultUserData;
```

### JSON Serialization:
```dart
// To JSON
final json = profile.toJson();

// From JSON
final profile = ProfileModel.fromJson(jsonData);
```

## Default Data

All models include default/placeholder data that matches the current UI:
- Jessica Davis profile information
- Sample health tracking data
- Default app settings
- Standard privacy configurations

This allows for easy testing and development without requiring backend integration.
