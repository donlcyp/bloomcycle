import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/calendar_data.dart';
import '../../models/cycle_history.dart';
import '../../services/firebase_service.dart';
import '../logs/symptoms_log.dart';
import '../logs/notes_log.dart';
import '../logs/notes_history.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime currentMonth;
  DateTime? cycleStartDate;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    _loadPeriodData();
  }

  Future<void> _loadPeriodData() async {
    // Load period days from CalendarData
    final periodDays = CalendarData.getPeriodDays();
    if (periodDays.isNotEmpty) {
      setState(() {
        cycleStartDate = periodDays.isNotEmpty 
            ? periodDays.reduce((a, b) => a.isBefore(b) ? a : b)
            : null;
      });
    }
  }

  void _markTodayAsCycleStart() {
    final now = DateTime.now();
    // Create list of 5 period days starting today
    final periodDays = <DateTime>[];
    for (int i = 0; i < 5; i++) {
      periodDays.add(DateTime(now.year, now.month, now.day + i));
    }
    
    setState(() {
      cycleStartDate = DateTime(now.year, now.month, now.day);
    });
    
    // Save period days to CalendarData
    CalendarData.setPeriodDays(periodDays);
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save to Firebase - store the period days and cycle start
      FirebaseService.saveCycleData(user.uid, {
        'cycleStart': cycleStartDate!,
        'periodDays': periodDays.map((d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}').toList(),
      });
    }
  }

  void _openDayDetailsBottomSheet(
    DateTime date,
    CalendarDay calendarDay,
    bool isCycleStart,
  ) {
    final existingNote = CalendarData.getNoteForDate(date);
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
                    : 'Tap an option below to log details for this day.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              if (isCycleStart)
                const Text(
                  'Marked as start of your menstrual cycle.',
                  style: TextStyle(fontSize: 13),
                ),
              if (calendarDay.isPeriodDay)
                const Text(
                  'This day is in a logged period.',
                  style: TextStyle(fontSize: 13),
                ),
              if (calendarDay.isFertileWindow)
                const Text(
                  'This day is in your fertile window.',
                  style: TextStyle(fontSize: 13),
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
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
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotesHistoryPage()),
                  );
                },
                icon: const Icon(Icons.notes, size: 18, color: Color(0xFFEC4899)),
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
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFFEC4899)),
              tooltip: 'Mark today as start of menstrual cycle',
              onPressed: _markTodayAsCycleStart,
            ),
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
    final calendarDays = CalendarData.getCalendarDays();
    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    List<Widget> dayWidgets = [];

    // Add empty spaces for days before the 1st
    for (int i = 0; i < startingWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 50));
    }

    // Add actual days
    for (var calendarDay in calendarDays) {
      final date = DateTime(
        currentMonth.year,
        currentMonth.month,
        calendarDay.day,
      );
      final isCycleStart =
          cycleStartDate != null &&
          date.year == cycleStartDate!.year &&
          date.month == cycleStartDate!.month &&
          date.day == cycleStartDate!.day;
      dayWidgets.add(
        GestureDetector(
          onTap: () =>
              _openDayDetailsBottomSheet(date, calendarDay, isCycleStart),
          child: _buildDayCell(calendarDay, isCycleStart),
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: dayWidgets);
  }

  Widget _buildDayCell(CalendarDay calendarDay, bool isCycleStart) {
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Colors.black;
    bool isOvulationDay = false;

    if (calendarDay.isToday) {
      backgroundColor = const Color(0xFFEC4899);
      textColor = Colors.white;
    }
    
    // Check if this date is a logged period day
    final date = DateTime(currentMonth.year, currentMonth.month, calendarDay.day);
    final isPeriodDay = CalendarData.isPeriodDay(date);
    
    // If cycle start is set, show cycle indicators
    if (cycleStartDate != null) {
      final daysFromStart = date.difference(cycleStartDate!).inDays;
      
      // Get average cycle length for accurate ovulation calculation
      final avgCycleLength = CycleHistoryData.averageCycleLength;
      final cycleLength = avgCycleLength > 0 ? avgCycleLength : 28; // Default to 28 if no data
      
      // Ovulation occurs at: cycleStart + (cycleLength - 14)
      final ovulationDay = cycleLength - 14;
      
      // Fertile window: 5 days before ovulation (Days 8-12 for 28-day cycle)
      // This is from (ovulationDay - 5) to (ovulationDay - 1)
      final fertileWindowStart = ovulationDay - 5;
      final fertileWindowEnd = ovulationDay - 1;
      
      // Show period days if they were marked
      if (isPeriodDay && !calendarDay.isToday) {
        backgroundColor = const Color(0xFFFCE7F3);
        borderColor = const Color(0xFFFCE7F3);
      } else if (daysFromStart >= fertileWindowStart && daysFromStart <= fertileWindowEnd && !calendarDay.isToday) {
        // Fertile window (Days 8-12 for 28-day cycle)
        backgroundColor = const Color(0xFFD1FAE5);
        borderColor = const Color(0xFFD1FAE5);
      }
      
      // Ovulation day
      if (daysFromStart == ovulationDay) {
        isOvulationDay = true;
      }
    }

    return Stack(
      children: [
        Container(
          width: 40,
          height: 50,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Center(
            child: Text(
              '${calendarDay.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: calendarDay.isToday
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
        if (isCycleStart)
          Positioned(
            bottom: 4,
            right: 4,
            child: Icon(
              Icons.close,
              size: 14,
              color: calendarDay.isToday
                  ? Colors.white
                  : const Color(0xFFEC4899),
            ),
          ),
        // Ovulation indicator (top-right dot)
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
        // Symptoms logged indicator (bottom dot)
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
        // Notes added indicator (bottom dot)
        if (calendarDay.hasNotesAdded)
          Positioned(
            bottom: 4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
      ],
    );
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
          // Period Days (shown after cycle start is set)
          _buildLegendRow(
            color: const Color(0xFFFCE7F3),
            label: 'Period Days (Days 0-4)',
            screenWidth: screenWidth,
          ),
          SizedBox(height: screenHeight * 0.01),
          // Fertile Window (shown after cycle start is set)
          _buildLegendRow(
            color: const Color(0xFFD1FAE5),
            label: 'Fertile Window (Days 8-12)',
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
            'ℹ️ Cycle colors appear after you mark your menstruation start date',
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
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
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
          'Ovulation Day (Day 14)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
