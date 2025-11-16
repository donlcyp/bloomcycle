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

  LegendItem({
    required this.label,
    required this.type,
  });
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
  static DateTime currentMonth = DateTime(2025, 11);
  static int todayDate = 16;

  static List<CalendarDay> getCalendarDays() {
    return [
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

  static List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
}
