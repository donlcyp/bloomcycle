class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String location;
  final String bio;
  final String avatarUrl;
  final DateTime memberSince;
  final int cycleLength;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.bio,
    required this.avatarUrl,
    required this.memberSince,
    required this.cycleLength,
  });

  String get fullName => '$firstName $lastName';
  
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'location': location,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'memberSince': memberSince.toIso8601String(),
      'cycleLength': cycleLength,
    };
  }

  // Create from JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      memberSince: DateTime.parse(json['memberSince'] ?? DateTime.now().toIso8601String()),
      cycleLength: json['cycleLength'] ?? 28,
    );
  }

  // Create a copy with updated fields
  ProfileModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? location,
    String? bio,
    String? avatarUrl,
    DateTime? memberSince,
    int? cycleLength,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
      cycleLength: cycleLength ?? this.cycleLength,
    );
  }

  // Default profile for testing/placeholder
  static ProfileModel get defaultProfile => ProfileModel(
    id: 'user_001',
    firstName: 'Jessica',
    lastName: 'Davis',
    email: 'jessica.davis@email.com',
    phoneNumber: '+1 (555) 123-4567',
    location: 'San Francisco, CA',
    bio: 'Health enthusiast passionate about wellness and mindful living. Love tracking my fitness journey and sharing tips with the community.',
    avatarUrl: '',
    memberSince: DateTime(2023, 3, 1),
    cycleLength: 28,
  );
}
