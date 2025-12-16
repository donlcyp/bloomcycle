import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/calendar_data.dart';
import '../../services/firebase_service.dart';
import '../logs/symptoms_log.dart';
import '../logs/notes_log.dart';
import '../logs/notes_history.dart';
import '../../state/user_state.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime currentMonth;
  DateTime? cycleStartDate;
  DateTime? _cycleSetTimestamp; // When the cycle start was set
  DateTime? _previousCycleStartDate; // For undo functionality
  int _cycleLength = 28;
  int _periodLength = 5;
  static const int _defaultLutealLength = 14;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    final settings = UserState.currentUser.settings.cycleSettings;
    setState(() {
      _cycleLength = settings.cycleLength;
      _periodLength = settings.periodLength;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final latest = await FirebaseService.getCycleData(user.uid);
      if (!mounted) return;
      if (latest == null) return;

      final start = latest['cycleStart'] as DateTime?;
      final storedCycleLength = latest['cycleLength'] as int?;
      final storedPeriodLength = latest['periodLength'] as int?;
      final setTimestamp = latest['cycleSetTimestamp'] as DateTime?;
      final previousStart = latest['previousCycleStart'] as DateTime?;

      setState(() {
        if (start != null) {
          cycleStartDate = DateTime(start.year, start.month, start.day);
        }
        _cycleLength = storedCycleLength ?? _cycleLength;
        _periodLength = storedPeriodLength ?? _periodLength;
        _cycleSetTimestamp = setTimestamp;
        if (previousStart != null) {
          _previousCycleStartDate = DateTime(previousStart.year, previousStart.month, previousStart.day);
        }
      });
    } catch (_) {
      // Ignore read failures; calendar will fallback to local settings.
    }
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  int _ovulationDayForCycle(int cycleLength) {
    final candidate = cycleLength - _defaultLutealLength;
    if (candidate >= 1 && candidate <= cycleLength) return candidate;
    return (cycleLength / 2).round().clamp(1, cycleLength);
  }

  ({int cycleDay, bool isPeriodDay, bool isFollicular, bool isFertileWindow, bool isLuteal, bool isMaybeFertile, bool isNotFertile, bool isOvulationDay})
  _predictionForDate(DateTime date) {
    final start = cycleStartDate;
    if (start == null) {
      return (
        cycleDay: 0,
        isPeriodDay: false,
        isFollicular: false,
        isFertileWindow: false,
        isLuteal: false,
        isMaybeFertile: false,
        isNotFertile: false,
        isOvulationDay: false,
      );
    }

    final normalizedDate = _dateOnly(date);
    final normalizedStart = _dateOnly(start);
    final diffDays = normalizedDate.difference(normalizedStart).inDays;

    // Only show predictions for past and current cycle.
    // Don't predict future cycles - wait for user to log new cycle start.
    // Current cycle ends at cycleStart + cycleLength - 1 days.
    final currentCycleEndDay = _cycleLength - 1;
    
    // If the date is beyond the current cycle, don't show predictions
    if (diffDays > currentCycleEndDay) {
      return (
        cycleDay: 0,
        isPeriodDay: false,
        isFollicular: false,
        isFertileWindow: false,
        isLuteal: false,
        isMaybeFertile: false,
        isNotFertile: false,
        isOvulationDay: false,
      );
    }

    // Support dates before start as well by using a positive modulo.
    final int cycleIndex = diffDays >= 0
        ? diffDays % _cycleLength
        : (_cycleLength - ((-diffDays) % _cycleLength)) % _cycleLength;
    final cycleDay = cycleIndex + 1;

    final periodLen = _periodLength.clamp(1, _cycleLength);
    final ovulationDay = _ovulationDayForCycle(_cycleLength);
    final fertileStart = (ovulationDay - 5).clamp(1, _cycleLength);
    final fertileEnd = (ovulationDay + 1).clamp(1, _cycleLength);
    
    // Maybe fertile: 2 days before fertile window and 2 days after
    final maybeFertileBeforeStart = (fertileStart - 2).clamp(1, _cycleLength);
    final maybeFertileAfterEnd = (fertileEnd + 2).clamp(1, _cycleLength);

    final isPeriodDay = cycleDay >= 1 && cycleDay <= periodLen;
    final isOvulationDay = cycleDay == ovulationDay;
    final isFertileWindow = cycleDay >= fertileStart && cycleDay <= fertileEnd;
    
    // Follicular phase: after period, before fertile window
    final isFollicular = !isPeriodDay && cycleDay > periodLen && cycleDay < maybeFertileBeforeStart;
    
    // Luteal phase: after fertile window ends (after maybe fertile ends)
    final isLuteal = cycleDay > maybeFertileAfterEnd;
    
    // Maybe fertile: days just before or after the fertile window (but not period days)
    final isMaybeFertile = !isPeriodDay && !isFertileWindow && !isFollicular && !isLuteal &&
        ((cycleDay >= maybeFertileBeforeStart && cycleDay < fertileStart) ||
         (cycleDay > fertileEnd && cycleDay <= maybeFertileAfterEnd));
    
    // Not fertile: shouldn't have any now since all days are categorized
    final isNotFertile = false;

    return (
      cycleDay: cycleDay,
      isPeriodDay: isPeriodDay,
      isFollicular: isFollicular,
      isFertileWindow: isFertileWindow,
      isLuteal: isLuteal,
      isMaybeFertile: isMaybeFertile,
      isNotFertile: isNotFertile,
      isOvulationDay: isOvulationDay,
    );
  }

  bool _canUndoCycleStart() {
    if (_cycleSetTimestamp == null || cycleStartDate == null) return false;
    final now = DateTime.now();
    final setDate = DateTime(_cycleSetTimestamp!.year, _cycleSetTimestamp!.month, _cycleSetTimestamp!.day);
    final today = DateTime(now.year, now.month, now.day);
    // Can only undo on the same day it was set
    return setDate.isAtSameMomentAs(today);
  }

  bool _hasCycleStartInMonth(DateTime date) {
    // Check if there's already a cycle start in the same month
    if (cycleStartDate == null) return false;
    return cycleStartDate!.year == date.year && 
           cycleStartDate!.month == date.month;
  }

  Future<void> _showCycleStartConfirmationForDate(DateTime selectedDate) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    // Prevent selecting future dates
    if (selected.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot set cycle start for a future date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if cycle start already exists in this month (and it's not the same day)
    if (_hasCycleStartInMonth(selected) && 
        !(cycleStartDate!.year == selected.year && 
          cycleStartDate!.month == selected.month && 
          cycleStartDate!.day == selected.day)) {
      final existingDateText = DateFormat('MMMM d').format(cycleStartDate!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cycle start already set for $existingDateText this month. Only one cycle start per month allowed.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    final isToday = selected.isAtSameMomentAs(today);
    final dateText = isToday 
        ? 'today' 
        : DateFormat('MMMM d, yyyy').format(selected);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Start Menstrual Cycle?'),
        content: Text(
          'Are you sure you want to mark $dateText as the start of your menstrual cycle?\n\n${isToday ? 'You can undo this action only within the same day.' : 'This will update your cycle tracking.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _markDateAsCycleStart(selected);
    }
  }

  void _markDateAsCycleStart(DateTime date) {
    final now = DateTime.now();
    final selected = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selected.isAtSameMomentAs(today);
    
    setState(() {
      _previousCycleStartDate = cycleStartDate;
      cycleStartDate = selected;
      // Only allow undo if set for today
      _cycleSetTimestamp = isToday ? now : null;
      final settings = UserState.currentUser.settings.cycleSettings;
      _cycleLength = settings.cycleLength;
      _periodLength = settings.periodLength;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final settings = UserState.currentUser.settings.cycleSettings;
      FirebaseService.saveCycleData(user.uid, {
        'cycleStart': cycleStartDate!,
        'cycleLength': settings.cycleLength,
        'periodLength': settings.periodLength,
        'cycleSetTimestamp': _cycleSetTimestamp,
        'previousCycleStart': _previousCycleStartDate,
      });
    }
    
    final dateText = isToday 
        ? 'today' 
        : DateFormat('MMM d').format(selected);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Menstrual cycle start marked for $dateText'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
  }

  // Keep old method for backward compatibility with the button
  Future<void> _showCycleStartConfirmation() async {
    await _showCycleStartConfirmationForDate(DateTime.now());
  }

  void _markTodayAsCycleStart() {
    _markDateAsCycleStart(DateTime.now());
  }

  Future<void> _showUndoCycleStartConfirmation() async {
    if (!_canUndoCycleStart()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only undo cycle start on the same day it was set'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Undo Cycle Start?'),
        content: const Text(
          'Are you sure you want to undo marking today as the start of your menstrual cycle?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _undoCycleStart();
    }
  }

  void _undoCycleStart() {
    setState(() {
      // Restore to previous cycle start date (preserves history)
      // Only removes the cycle start that was set today
      cycleStartDate = _previousCycleStartDate;
      _cycleSetTimestamp = null;
      _previousCycleStartDate = null;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final settings = UserState.currentUser.settings.cycleSettings;
      FirebaseService.saveCycleData(user.uid, {
        'cycleStart': cycleStartDate,
        'cycleLength': settings.cycleLength,
        'periodLength': settings.periodLength,
        'cycleSetTimestamp': null,
        'previousCycleStart': null,
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cycleStartDate != null 
            ? 'Cycle start undone. Restored to previous cycle.'
            : 'Cycle start has been undone'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _openDayDetailsBottomSheet(
    DateTime date,
    CalendarDay calendarDay,
    bool isCycleStart,
  ) {
    final existingNote = CalendarData.getNoteForDate(date);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);
    final isFutureDate = selectedDate.isAfter(today);
    // Check if there's already a cycle start in this month (different from current date)
    final hasCycleInMonth = _hasCycleStartInMonth(date) && !isCycleStart;
    
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE, MMM d').format(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                calendarDay.isToday
                    ? 'Today'
                    : isFutureDate
                        ? 'Future date'
                        : 'Tap an option below to log details for this day.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Set as cycle start - only for today and past dates, and only once per month
                  if (!isFutureDate && !isCycleStart && !hasCycleInMonth)
                    ActionChip(
                      avatar: const Icon(
                        Icons.play_circle_outline,
                        size: 18,
                        color: Color(0xFFEC4899),
                      ),
                      label: const Text('Set as cycle start'),
                      backgroundColor: const Color(0xFFEC4899).withValues(alpha: 0.1),
                      onPressed: () {
                        Navigator.pop(context);
                        _showCycleStartConfirmationForDate(date);
                      },
                    ),
                  ActionChip(
                    label: const Text('Log symptoms'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (context) => const SymptomsLogPage(),
                        ),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Add note'),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(this.context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotesLogPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isCycleStart)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFFEC4899), size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Marked as cycle start',
                        style: TextStyle(fontSize: 13, color: Color(0xFFEC4899), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              if (calendarDay.isPeriodDay && !isCycleStart)
                const Text(
                  'Menstrual Phase - Period day.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFEC4899)),
                ),
              if (calendarDay.isFollicular)
                const Text(
                  'Follicular Phase - Your body is preparing for ovulation.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF3B82F6)),
                ),
              if (calendarDay.isFertileWindow)
                const Text(
                  'Ovulation Phase - Peak fertility window.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF10B981)),
                ),
              if (calendarDay.isMaybeFertile)
                const Text(
                  'Transitional Phase - You might be fertile.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFEAB308)),
                ),
              if (calendarDay.isLuteal)
                const Text(
                  'Luteal Phase - PMS symptoms may occur.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFF97316)),
                ),
              if (calendarDay.isNotFertile)
                const Text(
                  'Set your cycle start date for predictions.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              if (calendarDay.hasOvulation)
                const Text(
                  'Ovulation indicator present.',
                  style: TextStyle(fontSize: 13),
                ),
              if (existingNote != null && existingNote.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Your note for this day:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  existingNote,
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFCE7F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(),
                SizedBox(height: screenHeight * 0.03),
                // Calendar
                _buildCalendar(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.03),
                // Legend
                _buildSimpleLegend(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Manage your cycle events',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotesHistoryPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.notes,
                  size: 18,
                  color: Color(0xFFEC4899),
                ),
                label: const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFEC4899),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFD946A6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: _previousMonth,
              ),
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 24),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_canUndoCycleStart())
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  tooltip: 'Undo cycle start',
                  onPressed: _showUndoCycleStartConfirmation,
                ),
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFEC4899)),
                tooltip: 'Mark today as start of menstrual cycle',
                onPressed: _showCycleStartConfirmation,
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          // Week days header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CalendarData.weekDays
                .map(
                  (day) => SizedBox(
                    width: 40,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final calendarDays = CalendarData.getCalendarDays(currentMonth);
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    // Build list of day data with phase info
    List<({CalendarDay day, String phase, bool isCycleStart})> daysData = [];

    for (var calendarDay in calendarDays) {
      final date = DateTime(
        currentMonth.year,
        currentMonth.month,
        calendarDay.day,
      );
      final prediction = _predictionForDate(date);
      final isCycleStart =
          cycleStartDate != null &&
          date.year == cycleStartDate!.year &&
          date.month == cycleStartDate!.month &&
          date.day == cycleStartDate!.day;

      final dayWithIndicators = CalendarDay(
        day: calendarDay.day,
        isToday: calendarDay.isToday,
        hasSymptomsLogged: CalendarData.hasSymptomsForDate(date),
        hasNotesAdded: CalendarData.hasNoteForDate(date),
        isPeriodDay: prediction.isPeriodDay,
        isFollicular: prediction.isFollicular,
        isFertileWindow: prediction.isFertileWindow,
        isLuteal: prediction.isLuteal,
        isMaybeFertile: prediction.isMaybeFertile,
        isNotFertile: prediction.isNotFertile,
        hasOvulation: prediction.isOvulationDay,
      );

      // Determine the phase for connectivity
      String phase = _getPhaseForDay(dayWithIndicators);
      daysData.add((day: dayWithIndicators, phase: phase, isCycleStart: isCycleStart));
    }

    List<Widget> rows = [];

    // Calculate total weeks needed
    final daysInMonth = calendarDays.length;
    final totalSlots = startingWeekday + daysInMonth;
    final totalWeeks = (totalSlots / 7).ceil();

    for (int week = 0; week < totalWeeks; week++) {
      List<Widget> rowChildren = [];

      for (int weekday = 0; weekday < 7; weekday++) {
        final slotIndex = week * 7 + weekday;
        final dayIndexInMonth = slotIndex - startingWeekday;

        if (dayIndexInMonth < 0 || dayIndexInMonth >= daysInMonth) {
          // Empty slot
          rowChildren.add(const SizedBox(width: 40, height: 50));
        } else {
          final data = daysData[dayIndexInMonth];
          final date = DateTime(currentMonth.year, currentMonth.month, data.day.day);

          // Check connectivity within the same row
          bool connectLeft = false;
          bool connectRight = false;

          // Check previous day in row (not first column)
          if (weekday > 0 && dayIndexInMonth > 0) {
            final prevData = daysData[dayIndexInMonth - 1];
            if (_shouldConnect(data.phase, prevData.phase, data.day.isToday, prevData.day.isToday)) {
              connectLeft = true;
            }
          }

          // Check next day in row (not last column)
          if (weekday < 6 && dayIndexInMonth < daysInMonth - 1) {
            final nextData = daysData[dayIndexInMonth + 1];
            if (_shouldConnect(data.phase, nextData.phase, data.day.isToday, nextData.day.isToday)) {
              connectRight = true;
            }
          }

          rowChildren.add(
            GestureDetector(
              onTap: () => _openDayDetailsBottomSheet(date, data.day, data.isCycleStart),
              child: _buildConnectedDayCell(
                data.day,
                data.isCycleStart,
                connectLeft: connectLeft,
                connectRight: connectRight,
              ),
            ),
          );
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren,
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  String _getPhaseForDay(CalendarDay day) {
    if (day.isToday) return 'today';
    if (day.isPeriodDay) return 'period';
    if (day.isFollicular) return 'follicular';
    if (day.isFertileWindow) return 'fertile';
    if (day.isMaybeFertile) return 'maybeFertile';
    if (day.isLuteal) return 'luteal';
    return 'none';
  }

  bool _shouldConnect(String phase1, String phase2, bool isToday1, bool isToday2) {
    // Don't connect if either is "today" or "none"
    if (phase1 == 'today' || phase2 == 'today') return false;
    if (phase1 == 'none' || phase2 == 'none') return false;
    return phase1 == phase2;
  }

  Widget _buildConnectedDayCell(
    CalendarDay calendarDay,
    bool isCycleStart, {
    bool connectLeft = false,
    bool connectRight = false,
  }) {
    Color? backgroundColor;
    Color textColor = Colors.black;
    bool isOvulationDay = false;

    if (calendarDay.isToday) {
      backgroundColor = const Color(0xFFEC4899);
      textColor = Colors.white;
    } else if (calendarDay.isPeriodDay) {
      backgroundColor = const Color(0xFFFCE7F3);
    } else if (calendarDay.isFollicular) {
      backgroundColor = const Color(0xFFDBEAFE);
    } else if (calendarDay.isFertileWindow) {
      backgroundColor = const Color(0xFFD1FAE5);
    } else if (calendarDay.isMaybeFertile) {
      backgroundColor = const Color(0xFFFEF9C3);
    } else if (calendarDay.isLuteal) {
      backgroundColor = const Color(0xFFFED7AA);
    }

    if (calendarDay.hasOvulation) {
      isOvulationDay = true;
    }

    // Calculate border radius based on connectivity
    double leftRadius = connectLeft ? 0 : 25;
    double rightRadius = connectRight ? 0 : 25;

    // For non-colored days, use circular style
    if (backgroundColor == null) {
      return Stack(
        children: [
          Container(
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: Center(
              child: Text(
                '${calendarDay.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ),
          ..._buildIndicators(calendarDay, isCycleStart, isOvulationDay),
        ],
      );
    }

    // For colored/connected days
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 50,
          margin: EdgeInsets.only(
            left: connectLeft ? 0 : 0,
            right: connectRight ? 0 : 0,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(leftRadius),
              bottomLeft: Radius.circular(leftRadius),
              topRight: Radius.circular(rightRadius),
              bottomRight: Radius.circular(rightRadius),
            ),
          ),
          child: Center(
            child: Text(
              '${calendarDay.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: calendarDay.isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
        // Connection strips to fill gaps
        if (connectRight)
          Positioned(
            right: -4,
            top: 0,
            bottom: 0,
            child: Container(
              width: 8,
              color: backgroundColor,
            ),
          ),
        ..._buildIndicators(calendarDay, isCycleStart, isOvulationDay),
      ],
    );
  }

  List<Widget> _buildIndicators(CalendarDay calendarDay, bool isCycleStart, bool isOvulationDay) {
    return [
      if (isCycleStart)
        Positioned(
          bottom: 4,
          right: 4,
          child: Icon(
            Icons.close,
            size: 14,
            color: calendarDay.isToday ? Colors.white : const Color(0xFFEC4899),
          ),
        ),
      if (isOvulationDay || calendarDay.hasOvulation)
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        ),
      if (calendarDay.hasSymptomsLogged)
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFEC4899),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      if (calendarDay.hasNotesAdded && !calendarDay.hasSymptomsLogged)
        Positioned(
          bottom: 4,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF6366F1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildSimpleLegend(double screenWidth, double screenHeight) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.015),
          // Today
          _buildLegendRow(
            color: const Color(0xFFEC4899),
            label: 'Today',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Period Days (Menstrual Phase)
          _buildLegendRow(
            color: const Color(0xFFFCE7F3),
            label: 'Period (Menstrual)',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Follicular Phase
          _buildLegendRow(
            color: const Color(0xFFDBEAFE),
            label: 'Follicular Phase',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Maybe Fertile (transition)
          _buildLegendRow(
            color: const Color(0xFFFEF9C3),
            label: 'Maybe Fertile',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Fertile Window (Ovulation Phase)
          _buildLegendRow(
            color: const Color(0xFFD1FAE5),
            label: 'Fertile (Ovulation)',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Luteal Phase
          _buildLegendRow(
            color: const Color(0xFFFED7AA),
            label: 'Luteal Phase (PMS)',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Not Fertile (no cycle set)
          _buildLegendRow(
            color: const Color(0xFFE5E7EB),
            label: 'Not Fertile',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Ovulation Day
          _buildOvulationLegendRow(screenWidth),
          SizedBox(height: screenHeight * 0.01),
          // Symptoms indicator
          _buildSymptomLegendRow(screenWidth),
          SizedBox(height: screenHeight * 0.01),
          // Notes indicator
          _buildNotesLegendRow(screenWidth),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'ℹ️ Predictions update after you mark your cycle start date and set cycle/period length.',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow({
    required Color color,
    required String label,
    required double screenWidth,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSymptomLegendRow(double screenWidth) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFFEC4899),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        const Text(
          'Symptoms Logged',
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildOvulationLegendRow(double screenWidth) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        const Text(
          'Ovulation Day',
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildNotesLegendRow(double screenWidth) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.03),
        const Text(
          'Notes Added',
          style: TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
