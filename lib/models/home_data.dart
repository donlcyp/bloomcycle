class CycleData {
  final int currentDay;
  final int daysLeft;
  final String currentPhase;
  final String nextDate;
  final double cycleProgress;

  CycleData({
    required this.currentDay,
    required this.daysLeft,
    required this.currentPhase,
    required this.nextDate,
    required this.cycleProgress,
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

class HomeData {
  static final CycleData cycleData = CycleData(
    currentDay: 14,
    daysLeft: 14,
    currentPhase: 'Ovulation',
    nextDate: 'Dec 28',
    cycleProgress: 0.4,
  );

  static final List<Insight> insights = [
    Insight(
      title: 'Peak Fertility',
      description: 'You are in your most fertile window. This is the best time to conceive.',
    ),
    Insight(
      title: 'Energy Levels',
      description: 'Expect high energy and increased motivation during this phase.',
    ),
  ];

  static final List<HealthTip> healthTips = [
    HealthTip(
      title: 'Ovulation Nutrition',
      description: 'During ovulation, you may benefit from foods rich in antioxidants...',
      category: 'nutrition',
    ),
    HealthTip(
      title: 'Exercise Tip',
      description: 'Light cardio and yoga are perfect for your ovulation phase...',
      category: 'exercise',
    ),
    HealthTip(
      title: 'Sleep Tips',
      description: 'Maintain a consistent sleep schedule to support your hormonal balance...',
      category: 'sleep',
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
