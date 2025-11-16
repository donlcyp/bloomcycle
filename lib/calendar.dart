import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/calendar_data.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = CalendarData.currentMonth;

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
                _buildLegend(screenWidth, screenHeight),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Center(
      child: Text(
        'Calendar',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
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
            color: Colors.black.withOpacity(0.1),
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
          SizedBox(height: screenHeight * 0.02),
          // Week days header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: CalendarData.weekDays
                .map((day) => SizedBox(
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
                    ))
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
      dayWidgets.add(_buildDayCell(calendarDay));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(CalendarDay calendarDay) {
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Colors.black;

    if (calendarDay.isToday) {
      backgroundColor = const Color(0xFFEC4899);
      textColor = Colors.white;
    } else if (calendarDay.isPeriodDay) {
      backgroundColor = const Color(0xFFFCE7F3);
      borderColor = const Color(0xFFFCE7F3);
    } else if (calendarDay.isFertileWindow) {
      backgroundColor = const Color(0xFFD1FAE5);
      borderColor = const Color(0xFFD1FAE5);
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
                fontWeight: calendarDay.isToday ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ),
        // Ovulation indicator (top-right dot)
        if (calendarDay.hasOvulation)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 6,
              height: 6,
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

  Widget _buildLegend(double screenWidth, double screenHeight) {
    final legendItems = CalendarData.getLegendItems();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ...legendItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLegendItem(item),
              )),
        ],
      ),
    );
  }

  Widget _buildLegendItem(LegendItem item) {
    Widget indicator;

    switch (item.type) {
      case LegendType.periodDays:
        indicator = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFFCE7F3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFFCE7F3), width: 1),
          ),
        );
        break;
      case LegendType.fertileWindow:
        indicator = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD1FAE5), width: 1),
          ),
        );
        break;
      case LegendType.today:
        indicator = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899),
            borderRadius: BorderRadius.circular(4),
          ),
        );
        break;
      case LegendType.ovulation:
        indicator = Container(
          width: 20,
          height: 20,
          alignment: Alignment.topRight,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
        );
        break;
      case LegendType.symptomsLogged:
        indicator = Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFEC4899),
              shape: BoxShape.circle,
            ),
          ),
        );
        break;
      case LegendType.notesAdded:
        indicator = Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        );
        break;
    }

    return Row(
      children: [
        indicator,
        const SizedBox(width: 12),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
