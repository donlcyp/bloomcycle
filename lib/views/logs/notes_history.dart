import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/calendar_data.dart';

class NotesHistoryPage extends StatelessWidget {
  const NotesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notesMap = CalendarData.getAllNotes();
    final entries = notesMap.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key)); // newest first

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes History'),
        backgroundColor: const Color(0xFFD946A6),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5E6E8),
      body: entries.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'You have not added any notes yet. Tap a day on the calendar and choose "Add note" to start.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final date = entry.key;
                final text = entry.value;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
