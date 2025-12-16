class CalendarDay {
  final int day;
  final bool isPeriodDay;
  final bool isFollicular;
  final bool isFertileWindow;
  final bool isLuteal;
  final bool isMaybeFertile;
  final bool isNotFertile;
  final bool isToday;
  final bool hasOvulation;
  final bool hasSymptomsLogged;
  final bool hasNotesAdded;

  CalendarDay({
    required this.day,
    this.isPeriodDay = false,
    this.isFollicular = false,
    this.isFertileWindow = false,
    this.isLuteal = false,
    this.isMaybeFertile = false,
    this.isNotFertile = false,
    this.isToday = false,
    this.hasOvulation = false,
    this.hasSymptomsLogged = false,
    this.hasNotesAdded = false,
  });
}

class LegendItem {
  final String label;
  final LegendType type;

  LegendItem({required this.label, required this.type});
}

enum LegendType {
  periodDays,
  follicular,
  fertileWindow,
  luteal,
  maybeFertile,
  notFertile,
  today,
  ovulation,
  symptomsLogged,
  notesAdded,
}

class CalendarData {
  static DateTime get currentMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  static int get todayDate {
    return DateTime.now().day;
  }

  // In-memory logs for the current session (not persisted)
  static final Map<String, bool> _symptomLogs = <String, bool>{};
  static final Map<String, String> _noteTexts = <String, String>{};

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static void logSymptomsForDate(DateTime date) {
    _symptomLogs[_dateKey(date)] = true;
  }

  static void logNoteForDate(DateTime date, String text) {
    final key = _dateKey(date);
    _noteTexts[key] = text;
  }

  static bool hasSymptomsForDate(DateTime date) {
    return _symptomLogs.containsKey(_dateKey(date));
  }

  static bool hasNoteForDate(DateTime date) {
    return _noteTexts.containsKey(_dateKey(date));
  }

  static String? getNoteForDate(DateTime date) {
    return _noteTexts[_dateKey(date)];
  }

  static Map<DateTime, String> getAllNotes() {
    final Map<DateTime, String> result = {};
    _noteTexts.forEach((key, value) {
      final parts = key.split('-');
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          result[DateTime(year, month, day)] = value;
        }
      }
    });
    return result;
  }

  static List<CalendarDay> getCalendarDays([DateTime? forMonth]) {
    // Generate empty calendar days - no cycle indicators by default
    final baseDays = <CalendarDay>[];
    final month = forMonth ?? currentMonth;
    
    // Get the number of days in the specified month
    final lastDayOfMonth = month.month == 12
        ? DateTime(month.year + 1, 1, 0).day
        : DateTime(month.year, month.month + 1, 0).day;

    for (int day = 1; day <= lastDayOfMonth; day++) {
      baseDays.add(CalendarDay(day: day));
    }

    return baseDays.map((day) {
      final date = DateTime(month.year, month.month, day.day);
      final hasSymptoms = hasSymptomsForDate(date);
      final hasNotes = hasNoteForDate(date);
      final now = DateTime.now();
      final isToday = date.day == now.day &&
          date.month == now.month &&
          date.year == now.year;

      return CalendarDay(
        day: day.day,
        isPeriodDay: false,
        isFertileWindow: false,
        isToday: isToday,
        hasOvulation: false,
        hasSymptomsLogged: hasSymptoms,
        hasNotesAdded: hasNotes,
      );
    }).toList();
  }

  static List<LegendItem> getLegendItems() {
    return [
      LegendItem(label: 'Period Days', type: LegendType.periodDays),
      LegendItem(label: 'Fertile Window', type: LegendType.fertileWindow),
      LegendItem(label: 'Today', type: LegendType.today),
      LegendItem(label: 'Ovulation', type: LegendType.ovulation),
      LegendItem(label: 'Symptoms Logged', type: LegendType.symptomsLogged),
      LegendItem(label: 'Notes Added', type: LegendType.notesAdded),
    ];
  }

  static List<String> weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
}
