class CalendarDay {
  final int day;
  final bool isPeriodDay;
  final bool isFertileWindow;
  final bool isToday;
  final bool hasOvulation;
  final bool hasSymptomsLogged;
  final bool hasNotesAdded;

  CalendarDay({
    required this.day,
    this.isPeriodDay = false,
    this.isFertileWindow = false,
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
  fertileWindow,
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

  static List<CalendarDay> getCalendarDays() {
    final baseDays = <CalendarDay>[
      CalendarDay(day: 1, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 2, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 3, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 4, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 5, isFertileWindow: true),
      CalendarDay(day: 6),
      CalendarDay(day: 7),
      CalendarDay(day: 8),
      CalendarDay(day: 9),
      CalendarDay(day: 10),
      CalendarDay(day: 11),
      CalendarDay(day: 12),
      CalendarDay(day: 13),
      CalendarDay(day: 14),
      CalendarDay(day: 15),
      CalendarDay(day: 16, isPeriodDay: true, isToday: true),
      CalendarDay(day: 17, isPeriodDay: true),
      CalendarDay(day: 18, isPeriodDay: true),
      CalendarDay(day: 19, isPeriodDay: true),
      CalendarDay(day: 20, isPeriodDay: true),
      CalendarDay(day: 21, isPeriodDay: true),
      CalendarDay(day: 22),
      CalendarDay(day: 23),
      CalendarDay(day: 24),
      CalendarDay(day: 25),
      CalendarDay(day: 26, isFertileWindow: true),
      CalendarDay(day: 27, isFertileWindow: true),
      CalendarDay(day: 28, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 29, isFertileWindow: true, hasOvulation: true),
      CalendarDay(day: 30, isFertileWindow: true, hasOvulation: true),
    ];

    return baseDays.map((day) {
      final date = DateTime(currentMonth.year, currentMonth.month, day.day);
      final hasSymptoms = hasSymptomsForDate(date);
      final hasNotes = hasNoteForDate(date);

      return CalendarDay(
        day: day.day,
        isPeriodDay: day.isPeriodDay,
        isFertileWindow: day.isFertileWindow,
        isToday: day.isToday,
        hasOvulation: day.hasOvulation,
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
