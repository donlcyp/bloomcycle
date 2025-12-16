/// Cycle phase-based predictions for moods and symptoms
/// Based on typical menstrual cycle phases and common experiences

enum CyclePhase {
  menstrual, // Period days (based on period length setting)
  follicular, // After period, before ovulation
  ovulation, // Around ovulation day (5 days window)
  luteal, // After ovulation until next period (typically 14 days)
  unknown, // No cycle data available
}

class CyclePredictions {
  /// Get the current cycle phase based on cycle day
  /// Uses the user's cycle length and period length settings
  static CyclePhase getPhase(int cycleDay, int cycleLength, int periodLength) {
    if (cycleDay <= 0 || cycleDay > cycleLength) return CyclePhase.unknown;

    // Period phase: Day 1 to periodLength
    if (cycleDay <= periodLength) {
      return CyclePhase.menstrual;
    }

    // Calculate ovulation day (typically 14 days before next period)
    // Luteal phase is relatively constant at ~14 days
    final lutealLength = 14;
    final ovulationDay = (cycleLength - lutealLength).clamp(
      periodLength + 1,
      cycleLength - 1,
    );

    // Follicular phase: After period until 2 days before ovulation
    if (cycleDay <= ovulationDay - 2) {
      return CyclePhase.follicular;
    }

    // Ovulation phase: 2 days before to 2 days after ovulation
    if (cycleDay <= ovulationDay + 2) {
      return CyclePhase.ovulation;
    }

    // Luteal phase: After ovulation until next period
    return CyclePhase.luteal;
  }

  /// Get phase day ranges based on cycle settings
  static Map<String, String> getPhaseRanges(int cycleLength, int periodLength) {
    final lutealLength = 14;
    final ovulationDay = (cycleLength - lutealLength).clamp(
      periodLength + 1,
      cycleLength - 1,
    );

    return {
      'menstrual': 'Days 1-$periodLength',
      'follicular': 'Days ${periodLength + 1}-${ovulationDay - 2}',
      'ovulation': 'Days ${ovulationDay - 2}-${ovulationDay + 2}',
      'luteal': 'Days ${ovulationDay + 3}-$cycleLength',
    };
  }

  /// Get a description with day range for the current phase
  static String getPhaseDescriptionWithDays(
    CyclePhase phase,
    int cycleLength,
    int periodLength,
  ) {
    final ranges = getPhaseRanges(cycleLength, periodLength);

    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase (${ranges['menstrual']}) - Rest and self-care';
      case CyclePhase.follicular:
        return 'Follicular Phase (${ranges['follicular']}) - Energy rising';
      case CyclePhase.ovulation:
        return 'Ovulation Phase (${ranges['ovulation']}) - Peak fertility';
      case CyclePhase.luteal:
        return 'Luteal/PMS Phase (${ranges['luteal']}) - PMS may occur';
      case CyclePhase.unknown:
        return 'Set your cycle start date to see predictions';
    }
  }

  /// Get predicted moods for the current cycle phase
  static List<String> getPredictedMoods(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return ['Tired', 'Emotional', 'Cranky', 'Sad', 'Calm'];
      case CyclePhase.follicular:
        return ['Happy', 'Confident', 'Excited', 'Peaceful', 'Calm'];
      case CyclePhase.ovulation:
        return ['Confident', 'Sexy', 'Romantic', 'Happy', 'Excited'];
      case CyclePhase.luteal:
        return [
          'Irritated',
          'Anxious',
          'Stressed',
          'Emotional',
          'Craving',
          'Frustrated',
        ];
      case CyclePhase.unknown:
        return [];
    }
  }

  /// Get predicted symptoms for the current cycle phase
  static List<String> getPredictedSymptoms(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return ['Cramps', 'Bloated', 'Tired', 'Headache', 'Achy', 'Weak'];
      case CyclePhase.follicular:
        return [
          // Generally fewer symptoms during this phase
        ];
      case CyclePhase.ovulation:
        return ['Mucus', 'Breast Tenderness', 'Bloated'];
      case CyclePhase.luteal:
        return [
          'PMS',
          'Bloated',
          'Breast Tenderness',
          'Acne',
          'Headache',
          'Craving',
          'Insomnia',
          'Tired',
        ];
      case CyclePhase.unknown:
        return [];
    }
  }

  /// Get a description of the current cycle phase
  static String getPhaseDescription(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase - Rest and self-care recommended';
      case CyclePhase.follicular:
        return 'Follicular Phase - Energy levels rising';
      case CyclePhase.ovulation:
        return 'Ovulation Phase - Peak energy and fertility';
      case CyclePhase.luteal:
        return 'Luteal Phase - PMS symptoms may occur';
      case CyclePhase.unknown:
        return 'Set your cycle start date to see predictions';
    }
  }

  /// Get phase name
  static String getPhaseName(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual';
      case CyclePhase.follicular:
        return 'Follicular';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal';
      case CyclePhase.unknown:
        return 'Unknown';
    }
  }

  /// Get phase color
  static int getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return 0xFFFCE7F3; // Light pink
      case CyclePhase.follicular:
        return 0xFFDCFCE7; // Light green
      case CyclePhase.ovulation:
        return 0xFFD1FAE5; // Green
      case CyclePhase.luteal:
        return 0xFFFEF9C3; // Light yellow
      case CyclePhase.unknown:
        return 0xFFE5E7EB; // Gray
    }
  }
}
