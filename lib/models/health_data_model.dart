class HealthDataModel {
  final CycleTrackingData cycleTracking;
  final WellnessStatsData wellnessStats;
  final HealthGoalsData healthGoals;

  HealthDataModel({
    required this.cycleTracking,
    required this.wellnessStats,
    required this.healthGoals,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'cycleTracking': cycleTracking.toJson(),
      'wellnessStats': wellnessStats.toJson(),
      'healthGoals': healthGoals.toJson(),
    };
  }

  // Create from JSON
  factory HealthDataModel.fromJson(Map<String, dynamic> json) {
    return HealthDataModel(
      cycleTracking: CycleTrackingData.fromJson(json['cycleTracking'] ?? {}),
      wellnessStats: WellnessStatsData.fromJson(json['wellnessStats'] ?? {}),
      healthGoals: HealthGoalsData.fromJson(json['healthGoals'] ?? {}),
    );
  }

  // Default health data for testing/placeholder
  static HealthDataModel get defaultHealthData => HealthDataModel(
    cycleTracking: CycleTrackingData.defaultData,
    wellnessStats: WellnessStatsData.defaultData,
    healthGoals: HealthGoalsData.defaultData,
  );
}

class CycleTrackingData {
  final int averageCycleLength;
  final DateTime? lastPeriodDate;
  final DateTime? nextExpectedDate;

  CycleTrackingData({
    required this.averageCycleLength,
    this.lastPeriodDate,
    this.nextExpectedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'averageCycleLength': averageCycleLength,
      'lastPeriodDate': lastPeriodDate?.toIso8601String(),
      'nextExpectedDate': nextExpectedDate?.toIso8601String(),
    };
  }

  factory CycleTrackingData.fromJson(Map<String, dynamic> json) {
    return CycleTrackingData(
      averageCycleLength: json['averageCycleLength'] ?? 28,
      lastPeriodDate: json['lastPeriodDate'] != null 
          ? DateTime.parse(json['lastPeriodDate']) 
          : null,
      nextExpectedDate: json['nextExpectedDate'] != null 
          ? DateTime.parse(json['nextExpectedDate']) 
          : null,
    );
  }

  static CycleTrackingData get defaultData => CycleTrackingData(
    averageCycleLength: 28,
    lastPeriodDate: DateTime(2024, 12, 15),
    nextExpectedDate: DateTime(2025, 1, 12),
  );
}

class WellnessStatsData {
  final int daysTracked;
  final int moodEntries;
  final int symptomsLogged;

  WellnessStatsData({
    required this.daysTracked,
    required this.moodEntries,
    required this.symptomsLogged,
  });

  Map<String, dynamic> toJson() {
    return {
      'daysTracked': daysTracked,
      'moodEntries': moodEntries,
      'symptomsLogged': symptomsLogged,
    };
  }

  factory WellnessStatsData.fromJson(Map<String, dynamic> json) {
    return WellnessStatsData(
      daysTracked: json['daysTracked'] ?? 0,
      moodEntries: json['moodEntries'] ?? 0,
      symptomsLogged: json['symptomsLogged'] ?? 0,
    );
  }

  static WellnessStatsData get defaultData => WellnessStatsData(
    daysTracked: 287,
    moodEntries: 156,
    symptomsLogged: 89,
  );
}

class HealthGoalsData {
  final double dailyWaterIntakeProgress;
  final double exerciseGoalsProgress;
  final int dailyWaterIntakeTarget; // in ml
  final int exerciseMinutesTarget;

  HealthGoalsData({
    required this.dailyWaterIntakeProgress,
    required this.exerciseGoalsProgress,
    required this.dailyWaterIntakeTarget,
    required this.exerciseMinutesTarget,
  });

  Map<String, dynamic> toJson() {
    return {
      'dailyWaterIntakeProgress': dailyWaterIntakeProgress,
      'exerciseGoalsProgress': exerciseGoalsProgress,
      'dailyWaterIntakeTarget': dailyWaterIntakeTarget,
      'exerciseMinutesTarget': exerciseMinutesTarget,
    };
  }

  factory HealthGoalsData.fromJson(Map<String, dynamic> json) {
    return HealthGoalsData(
      dailyWaterIntakeProgress: (json['dailyWaterIntakeProgress'] ?? 0.0).toDouble(),
      exerciseGoalsProgress: (json['exerciseGoalsProgress'] ?? 0.0).toDouble(),
      dailyWaterIntakeTarget: json['dailyWaterIntakeTarget'] ?? 2000,
      exerciseMinutesTarget: json['exerciseMinutesTarget'] ?? 30,
    );
  }

  static HealthGoalsData get defaultData => HealthGoalsData(
    dailyWaterIntakeProgress: 0.8, // 80%
    exerciseGoalsProgress: 0.6, // 60%
    dailyWaterIntakeTarget: 2000, // 2L
    exerciseMinutesTarget: 30, // 30 minutes
  );
}
