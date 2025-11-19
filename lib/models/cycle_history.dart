class CycleHistoryEntry {
  final DateTime startDate;
  final int cycleLengthDays;
  final int periodLengthDays;

  CycleHistoryEntry({
    required this.startDate,
    required this.cycleLengthDays,
    required this.periodLengthDays,
  });
}

class CycleHistoryData {
  // Demo data for 4 recent cycles. Adjust as needed.
  static final List<CycleHistoryEntry> recentCycles = [
    CycleHistoryEntry(
      startDate: DateTime(2025, 11, 16),
      cycleLengthDays: 28,
      periodLengthDays: 5,
    ),
    CycleHistoryEntry(
      startDate: DateTime(2025, 10, 19),
      cycleLengthDays: 29,
      periodLengthDays: 5,
    ),
    CycleHistoryEntry(
      startDate: DateTime(2025, 9, 21),
      cycleLengthDays: 27,
      periodLengthDays: 4,
    ),
    CycleHistoryEntry(
      startDate: DateTime(2025, 8, 24),
      cycleLengthDays: 28,
      periodLengthDays: 5,
    ),
  ];

  static int get averageCycleLength {
    if (recentCycles.isEmpty) return 0;
    final total = recentCycles.fold<int>(
      0,
      (sum, c) => sum + c.cycleLengthDays,
    );
    return (total / recentCycles.length).round();
  }

  static int get averagePeriodLength {
    if (recentCycles.isEmpty) return 0;
    final total = recentCycles.fold<int>(
      0,
      (sum, c) => sum + c.periodLengthDays,
    );
    return (total / recentCycles.length).round();
  }
}
