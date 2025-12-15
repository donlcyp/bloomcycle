class SymptomSurvey {
  final String id;
  final String symptom;
  final int totalResponses;
  final Map<String, int> phaseDistribution;
  final double averageSeverity;
  final String userResponse;

  SymptomSurvey({
    required this.id,
    required this.symptom,
    required this.totalResponses,
    required this.phaseDistribution,
    required this.averageSeverity,
    required this.userResponse,
  });
}

class WellnessChallenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final int participantCount;
  final bool userParticipating;
  final double userProgress;
  final List<String> rewards;

  WellnessChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.participantCount,
    required this.userParticipating,
    required this.userProgress,
    required this.rewards,
  });
}

class CommunityStats {
  final int totalUsers;
  final int activeChallenges;
  final int completedChallenges;
  final List<SymptomSurvey> activeSurveys;
  final List<WellnessChallenge> upcomingChallenges;

  CommunityStats({
    required this.totalUsers,
    required this.activeChallenges,
    required this.completedChallenges,
    required this.activeSurveys,
    required this.upcomingChallenges,
  });
}

class ChallengeParticipation {
  final String challengeId;
  final String userId;
  final DateTime joinedDate;
  final double progressPercentage;
  final int daysCompleted;
  final bool completed;

  ChallengeParticipation({
    required this.challengeId,
    required this.userId,
    required this.joinedDate,
    required this.progressPercentage,
    required this.daysCompleted,
    required this.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'joinedDate': joinedDate.toIso8601String(),
      'progressPercentage': progressPercentage,
      'daysCompleted': daysCompleted,
      'completed': completed,
    };
  }

  factory ChallengeParticipation.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipation(
      challengeId: json['challengeId'] ?? '',
      userId: json['userId'] ?? '',
      joinedDate: DateTime.tryParse(json['joinedDate'] ?? '') ?? DateTime.now(),
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      daysCompleted: json['daysCompleted'] ?? 0,
      completed: json['completed'] ?? false,
    );
  }
}
