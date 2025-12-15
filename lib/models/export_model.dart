class ExportReport {
  final String title;
  final String generatedDate;
  final String cycleInfo;
  final String symptomsData;
  final String moodData;
  final String insightsData;
  final String recommendations;

  ExportReport({
    required this.title,
    required this.generatedDate,
    required this.cycleInfo,
    required this.symptomsData,
    required this.moodData,
    required this.insightsData,
    required this.recommendations,
  });

  String toCsvFormat() {
    return '''BloomCycle Health Report
Generated: $generatedDate

CYCLE INFORMATION
$cycleInfo

SYMPTOMS DATA
$symptomsData

MOOD DATA
$moodData

INSIGHTS
$insightsData

RECOMMENDATIONS
$recommendations
''';
  }

  String toPdfFormat() {
    return '''
═══════════════════════════════════════════════════════════
                    BLOOMCYCLE HEALTH REPORT
═══════════════════════════════════════════════════════════

Generated: $generatedDate

───────────────────────────────────────────────────────────
CYCLE INFORMATION
───────────────────────────────────────────────────────────
$cycleInfo

───────────────────────────────────────────────────────────
SYMPTOMS SUMMARY
───────────────────────────────────────────────────────────
$symptomsData

───────────────────────────────────────────────────────────
MOOD PATTERNS
───────────────────────────────────────────────────────────
$moodData

───────────────────────────────────────────────────────────
KEY INSIGHTS
───────────────────────────────────────────────────────────
$insightsData

───────────────────────────────────────────────────────────
RECOMMENDATIONS
───────────────────────────────────────────────────────────
$recommendations

═══════════════════════════════════════════════════════════
This report is for personal health tracking purposes only.
Please consult a healthcare professional for medical advice.
═══════════════════════════════════════════════════════════
''';
  }
}

class ShareSettings {
  final bool includeSymptoms;
  final bool includeMood;
  final bool includeInsights;
  final bool includeRecommendations;
  final String shareMethod;

  ShareSettings({
    required this.includeSymptoms,
    required this.includeMood,
    required this.includeInsights,
    required this.includeRecommendations,
    required this.shareMethod,
  });

  ShareSettings copyWith({
    bool? includeSymptoms,
    bool? includeMood,
    bool? includeInsights,
    bool? includeRecommendations,
    String? shareMethod,
  }) {
    return ShareSettings(
      includeSymptoms: includeSymptoms ?? this.includeSymptoms,
      includeMood: includeMood ?? this.includeMood,
      includeInsights: includeInsights ?? this.includeInsights,
      includeRecommendations:
          includeRecommendations ?? this.includeRecommendations,
      shareMethod: shareMethod ?? this.shareMethod,
    );
  }
}
