class CycleData {
  final int currentDay;
  final int daysLeft;
  final String currentPhase;
  final String nextDate;
  final double cycleProgress;
  final int totalCycleDays;

  CycleData({
    required this.currentDay,
    required this.daysLeft,
    required this.currentPhase,
    required this.nextDate,
    required this.cycleProgress,
    required this.totalCycleDays,
  });
}

class Insight {
  final String title;
  final String description;

  Insight({
    required this.title,
    required this.description,
  });
}

class HealthTip {
  final String title;
  final String description;
  final String category;

  HealthTip({
    required this.title,
    required this.description,
    required this.category,
  });
}

class QuickAction {
  final String title;
  final String subtitle;
  final String iconName;
  final int colorValue;

  QuickAction({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorValue,
  });
}

class TodaysTip {
  final String title;
  final String description;
  final String iconName;

  TodaysTip({
    required this.title,
    required this.description,
    required this.iconName,
  });
}

class HomeData {
  static String _calculatePhase(int currentDay) {
    if (currentDay >= 1 && currentDay <= 5) {
      return 'Menstruation';
    } else if (currentDay >= 6 && currentDay <= 13) {
      return 'Follicular';
    } else if (currentDay >= 14 && currentDay <= 15) {
      return 'Ovulation';
    } else {
      return 'Luteal';
    }
  }

  static final CycleData cycleData = CycleData(
    currentDay: 14,
    daysLeft: 14,
    currentPhase: _calculatePhase(14),
    nextDate: 'Day 28',
    cycleProgress: 14 / 28,
    totalCycleDays: 28,
  );

  static const Map<String, int> healthTipColors = {
    'nutrition': 0xFFD946A6,
    'exercise': 0xFF3B82F6,
  };

  static const Map<String, String> healthTipIcons = {
    'nutrition': 'restaurant',
    'exercise': 'fitness_center',
  };

  static final List<QuickAction> quickActions = [
    QuickAction(
      title: 'Notes',
      subtitle: 'Record daily observations',
      iconName: 'description',
      colorValue: 0xFFD946A6,
    ),
    QuickAction(
      title: 'Symptoms',
      subtitle: 'Log physical symptoms',
      iconName: 'favorite',
      colorValue: 0xFF3B82F6,
    ),
    QuickAction(
      title: 'Mood',
      subtitle: 'Track emotional wellness',
      iconName: 'emoji_emotions',
      colorValue: 0xFF10B981,
    ),
  ];

  static final Insight todaysInsight = Insight(
    title: 'Ovulation Phase Active',
    description: 'Your fertility window is at its peak. Consider tracking basal body temperature for more accurate predictions.',
  );

  static final TodaysTip todaysTip = TodaysTip(
    title: 'Hydration Focus',
    description: 'During ovulation, increase your water intake to support cervical mucus production and overall reproductive health.',
    iconName: 'water_drop',
  );

  static final List<HealthTip> healthTips = [
    HealthTip(
      title: 'Ovulation Nutrition',
      description: 'Focus on antioxidant-rich foods like berries and leafy greens during your fertile window.',
      category: 'nutrition',
    ),
    HealthTip(
      title: 'Exercise Tip',
      description: 'Light cardio and yoga are perfect for your current cycle phase.',
      category: 'exercise',
    ),
  ];

  static final List<String> recentActivities = [
    'Logged period - 2 days ago',
    'Logged symptoms - 5 days ago',
    'Added health note - 1 week ago',
  ];

  static final List<String> symptoms = [
    'Headache',
    'Fatigue',
    'Mood changes',
    'Cramps',
    'Bloating',
  ];
}
