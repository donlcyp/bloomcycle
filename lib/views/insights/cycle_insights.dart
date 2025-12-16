import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/cycle_insights_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/design_system.dart';
import '../../theme/responsive_helper.dart';

class CycleInsightsPage extends StatefulWidget {
  const CycleInsightsPage({super.key});

  @override
  State<CycleInsightsPage> createState() => _CycleInsightsPageState();
}

class _CycleInsightsPageState extends State<CycleInsightsPage> {
  late Future<CycleStats> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _insightsFuture = _loadInsights();
  }

  Future<CycleStats> _loadInsights() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return _emptyStats();
    }

    try {
      final cycles = await FirebaseService.getCycles(user.uid);
      final symptoms = await FirebaseService.getSymptoms(user.uid);
      final moods = await FirebaseService.getMoodHistory(user.uid);

      return _analyzeData(cycles, symptoms, moods);
    } catch (e) {
      return _emptyStats();
    }
  }

  CycleStats _analyzeData(
    List<Map<String, dynamic>> cycles,
    List<Map<String, dynamic>> symptoms,
    List<Map<String, dynamic>> moods,
  ) {
    final totalCycles = cycles.length;
    final avgLength = totalCycles > 0
        ? cycles
                  .map((c) => (c['cycleLength'] as int?) ?? 28)
                  .reduce((a, b) => a + b) /
              totalCycles
        : 28.0;

    final cycleLengths = cycles
        .map((c) => (c['cycleLength'] as int?) ?? 28)
        .toList();
    final regularity = _calculateRegularity(cycleLengths);

    final topSymptoms = _analyzeSymptoms(symptoms);
    final moodPatterns = _analyzeMoods(moods);
    final patterns = _identifyPatterns(symptoms, moods, cycles);

    // Calculate cycle phase and predictions
    final lastCycleStart = cycles.isNotEmpty
        ? DateTime.tryParse(cycles.last['startDate'] as String? ?? '')
        : null;
    final phaseInfo = _calculateCyclePhase(lastCycleStart, avgLength.toInt());
    final nextPeriod = _predictNextPeriod(lastCycleStart, avgLength.toInt());
    final fertilityWindow = _calculateFertilityWindow(
      lastCycleStart,
      avgLength.toInt(),
    );

    return CycleStats(
      totalCyclesTracked: totalCycles,
      averageCycleLength: avgLength,
      cycleRegularity: regularity,
      totalSymptomLogs: symptoms.length,
      totalMoodLogs: moods.length,
      topSymptoms: topSymptoms,
      moodPatterns: moodPatterns,
      patterns: patterns,
      currentPhase: phaseInfo['phase'] as String,
      daysIntoPhase: phaseInfo['daysInto'] as int,
      nextPeriodDate: nextPeriod,
      predictionConfidence: regularity,
      fertilityWindowStart: fertilityWindow['start'],
      fertilityWindowEnd: fertilityWindow['end'],
    );
  }

  Map<String, dynamic> _calculateCyclePhase(
    DateTime? startDate,
    int cycleLength,
  ) {
    if (startDate == null) {
      return {'phase': 'Unknown', 'daysInto': 0};
    }

    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    final dayInCycle = daysSinceStart % cycleLength;

    String phase;
    if (dayInCycle < 5) {
      phase = 'Menstruation';
    } else if (dayInCycle < 13) {
      phase = 'Follicular';
    } else if (dayInCycle < 15) {
      phase = 'Ovulation';
    } else {
      phase = 'Luteal';
    }

    return {'phase': phase, 'daysInto': dayInCycle};
  }

  DateTime? _predictNextPeriod(DateTime? startDate, int cycleLength) {
    if (startDate == null) return null;

    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    final cycleNumber = (daysSinceStart / cycleLength).ceil();
    return startDate.add(Duration(days: cycleNumber * cycleLength));
  }

  Map<String, DateTime?> _calculateFertilityWindow(
    DateTime? startDate,
    int cycleLength,
  ) {
    if (startDate == null) {
      return {'start': null, 'end': null};
    }

    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    final dayInCycle = daysSinceStart % cycleLength;

    // Ovulation typically occurs around day 14 of a 28-day cycle
    final ovulationDay = (cycleLength * 0.5).toInt();
    final fertilityStart = ovulationDay - 5;
    final fertilityEnd = ovulationDay + 1;

    final currentCycleStart = startDate.add(
      Duration(days: (daysSinceStart ~/ cycleLength) * cycleLength),
    );

    return {
      'start': currentCycleStart.add(Duration(days: fertilityStart)),
      'end': currentCycleStart.add(Duration(days: fertilityEnd)),
    };
  }

  double _calculateRegularity(List<int> lengths) {
    if (lengths.isEmpty || lengths.length < 2) return 1.0;
    final avg = lengths.reduce((a, b) => a + b) / lengths.length;
    final variance =
        lengths.map((l) => (l - avg).abs()).reduce((a, b) => a + b) /
        lengths.length;
    return (1 - (variance / avg)).clamp(0.0, 1.0);
  }

  List<SymptomTrend> _analyzeSymptoms(List<Map<String, dynamic>> symptoms) {
    final symptomMap = <String, int>{};
    for (final symptom in symptoms) {
      final list = (symptom['symptoms'] as List?)?.cast<String>() ?? [];
      for (final s in list) {
        symptomMap[s] = (symptomMap[s] ?? 0) + 1;
      }
    }

    return symptomMap.entries
        .map(
          (e) => SymptomTrend(
            symptom: e.key,
            occurrences: e.value,
            phases: ['Menstruation', 'Follicular'],
            severity: (e.value / symptoms.length).clamp(0.0, 1.0),
          ),
        )
        .toList()
      ..sort((a, b) => b.occurrences.compareTo(a.occurrences));
  }

  List<MoodTrend> _analyzeMoods(List<Map<String, dynamic>> moods) {
    final moodMap = <String, List<int>>{};
    for (final mood in moods) {
      final moodName = mood['mood'] as String? ?? 'Unknown';
      final intensity = (mood['intensity'] as int?) ?? 3;
      moodMap.putIfAbsent(moodName, () => []).add(intensity);
    }

    return moodMap.entries
        .map(
          (e) => MoodTrend(
            mood: e.key,
            count: e.value.length,
            averageIntensity: e.value.reduce((a, b) => a + b) / e.value.length,
            commonPhases: ['Follicular', 'Ovulation'],
          ),
        )
        .toList()
      ..sort((a, b) => b.count.compareTo(a.count));
  }

  List<CyclePattern> _identifyPatterns(
    List<Map<String, dynamic>> symptoms,
    List<Map<String, dynamic>> moods,
    List<Map<String, dynamic>> cycles,
  ) {
    final patterns = <CyclePattern>[];

    if (symptoms.isNotEmpty) {
      patterns.add(
        CyclePattern(
          pattern: 'Consistent Tracking',
          description: 'You\'ve logged ${symptoms.length} symptom entries',
          confidence: 0.95,
          recommendation: 'Keep tracking to identify more patterns!',
        ),
      );
    }

    if (cycles.isNotEmpty && cycles.length > 2) {
      final lengths = cycles
          .map((c) => (c['cycleLength'] as int?) ?? 28)
          .toList();
      final isRegular = _calculateRegularity(lengths) > 0.8;
      patterns.add(
        CyclePattern(
          pattern: isRegular ? 'Regular Cycles' : 'Variable Cycles',
          description: isRegular
              ? 'Your cycles are very consistent'
              : 'Your cycle length varies slightly',
          confidence: 0.85,
          recommendation: isRegular
              ? 'Your predictability is excellent!'
              : 'Track more cycles to improve predictions',
        ),
      );
    }

    return patterns;
  }

  CycleStats _emptyStats() {
    return CycleStats(
      totalCyclesTracked: 0,
      averageCycleLength: 28,
      cycleRegularity: 0,
      totalSymptomLogs: 0,
      totalMoodLogs: 0,
      topSymptoms: [],
      moodPatterns: [],
      patterns: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FA),
      appBar: AppBar(
        title: const Text('Cycle Insights'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<CycleStats>(
        future: _insightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = snapshot.data ?? _emptyStats();
          final padding = ResponsiveHelper.getHorizontalPadding(context);
          final spacing = ResponsiveHelper.getSpacing(
            context,
            small: 16,
            medium: 20,
            large: 24,
          );

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: padding,
              right: padding,
              top: padding,
              bottom: padding + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCyclePhaseIndicator(stats, theme, media),
                SizedBox(height: spacing),
                _buildPeriodPrediction(stats, theme, media),
                SizedBox(height: spacing),
                _buildStatsOverview(stats, theme, media),
                SizedBox(height: spacing),
                _buildTopSymptoms(stats, theme, media),
                SizedBox(height: spacing),
                _buildMoodPatterns(stats, theme, media),
                SizedBox(height: spacing),
                _buildPatterns(stats, theme, media),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCyclePhaseIndicator(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    final phaseColor = _getPhaseColor(stats.currentPhase);
    final phaseEmoji = _getPhaseEmoji(stats.currentPhase);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            phaseColor.withValues(alpha: 0.1),
            phaseColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(phaseEmoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Phase',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      stats.currentPhase,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: phaseColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${stats.daysIntoPhase + 1}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'of this phase',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPhaseDescription(stats.currentPhase),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: phaseColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodPrediction(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    if (stats.nextPeriodDate == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period Prediction',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Log your cycle to get predictions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    final daysUntilPeriod = stats.nextPeriodDate!
        .difference(DateTime.now())
        .inDays;
    final confidence = (stats.predictionConfidence * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Period',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'In $daysUntilPeriod days',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF6B6B),
                    ),
                  ),
                  Text(
                    _formatDate(stats.nextPeriodDate!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$confidence%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                    Text(
                      'Confidence',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (stats.fertilityWindowStart != null &&
              stats.fertilityWindowEnd != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD93D).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    color: Color(0xFFFFD93D),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fertility window: ${_formatDate(stats.fertilityWindowStart!)} - ${_formatDate(stats.fertilityWindowEnd!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPhaseColor(String phase) {
    switch (phase) {
      case 'Menstruation':
        return const Color(0xFFFF6B6B);
      case 'Follicular':
        return const Color(0xFF4DABF7);
      case 'Ovulation':
        return const Color(0xFFFFD93D);
      case 'Luteal':
        return const Color(0xFFD946A6);
      default:
        return Colors.grey;
    }
  }

  String _getPhaseEmoji(String phase) {
    switch (phase) {
      case 'Menstruation':
        return '🩸';
      case 'Follicular':
        return '🌱';
      case 'Ovulation':
        return '✨';
      case 'Luteal':
        return '🌙';
      default:
        return '❓';
    }
  }

  String _getPhaseDescription(String phase) {
    switch (phase) {
      case 'Menstruation':
        return 'Rest & Recover';
      case 'Follicular':
        return 'Energy Rising';
      case 'Ovulation':
        return 'Peak Energy';
      case 'Luteal':
        return 'Slow Down';
      default:
        return 'Unknown';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  Widget _buildStatsOverview(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Cycle Overview',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  '${stats.totalCyclesTracked}',
                  'Cycles Tracked',
                  const Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  '${stats.averageCycleLength.toStringAsFixed(0)} days',
                  'Avg Length',
                  const Color(0xFF4DABF7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  '${(stats.cycleRegularity * 100).toStringAsFixed(0)}%',
                  'Regularity',
                  const Color(0xFF51CF66),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  '${stats.totalSymptomLogs}',
                  'Symptoms Logged',
                  const Color(0xFFFFD93D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTopSymptoms(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Symptoms',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.topSymptoms.isEmpty)
            Text(
              'Log symptoms to see patterns',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            )
          else
            ...stats.topSymptoms.take(5).map((symptom) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          symptom.symptom,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${symptom.occurrences}x',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: symptom.severity,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD946A6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildMoodPatterns(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Patterns',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.moodPatterns.isEmpty)
            Text(
              'Log moods to see patterns',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            )
          else
            ...stats.moodPatterns.take(4).map((mood) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF3FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD946A6).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mood.mood,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${mood.count} times',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Avg intensity: ${mood.averageIntensity.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPatterns(
    CycleStats stats,
    ThemeData theme,
    MediaQueryData media,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (stats.patterns.isEmpty)
            Text(
              'Keep tracking to unlock insights',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            )
          else
            ...stats.patterns.map((pattern) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pattern.pattern,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pattern.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pattern.recommendation,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
