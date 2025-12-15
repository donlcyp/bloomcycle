class CycleInsight {
  final String title;
  final String description;
  final String category;
  final IconType iconType;

  CycleInsight({
    required this.title,
    required this.description,
    required this.category,
    required this.iconType,
  });
}

enum IconType { symptom, mood, pattern, prediction, health }

class SymptomTrend {
  final String symptom;
  final int occurrences;
  final List<String> phases;
  final double severity;

  SymptomTrend({
    required this.symptom,
    required this.occurrences,
    required this.phases,
    required this.severity,
  });
}

class MoodTrend {
  final String mood;
  final int count;
  final double averageIntensity;
  final List<String> commonPhases;

  MoodTrend({
    required this.mood,
    required this.count,
    required this.averageIntensity,
    required this.commonPhases,
  });
}

class CyclePattern {
  final String pattern;
  final String description;
  final double confidence;
  final String recommendation;

  CyclePattern({
    required this.pattern,
    required this.description,
    required this.confidence,
    required this.recommendation,
  });
}

class CycleStats {
  final int totalCyclesTracked;
  final double averageCycleLength;
  final double cycleRegularity;
  final int totalSymptomLogs;
  final int totalMoodLogs;
  final List<SymptomTrend> topSymptoms;
  final List<MoodTrend> moodPatterns;
  final List<CyclePattern> patterns;
  final String currentPhase;
  final int daysIntoPhase;
  final DateTime? nextPeriodDate;
  final double predictionConfidence;
  final DateTime? fertilityWindowStart;
  final DateTime? fertilityWindowEnd;

  CycleStats({
    required this.totalCyclesTracked,
    required this.averageCycleLength,
    required this.cycleRegularity,
    required this.totalSymptomLogs,
    required this.totalMoodLogs,
    required this.topSymptoms,
    required this.moodPatterns,
    required this.patterns,
    this.currentPhase = 'Unknown',
    this.daysIntoPhase = 0,
    this.nextPeriodDate,
    this.predictionConfidence = 0.0,
    this.fertilityWindowStart,
    this.fertilityWindowEnd,
  });
}
