import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';

class SymptomsLogPage extends StatefulWidget {
  const SymptomsLogPage({super.key});

  @override
  State<SymptomsLogPage> createState() => _SymptomsLogPageState();
}

class _SymptomsLogPageState extends State<SymptomsLogPage> {
  final TextEditingController _notesController = TextEditingController();
  final Set<String> _selectedSymptoms = <String>{};
  late DateTime _selectedDate;

  final List<String> _symptomOptions = <String>[
    'Cramps',
    'Headache',
    'Bloating',
    'Breast tenderness',
    'Fatigue',
    'Mood changes',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptoms'),
        backgroundColor: const Color(0xFFD946A6),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5E6E8),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD946A6), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Logging for:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD946A6),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD946A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Which symptoms are you noticing?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptomOptions.map((symptom) {
                final selected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: selected,
                  selectedColor: const Color(0xFFFCE7F3),
                  checkmarkColor: const Color(0xFFD946A6),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Notes (optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Add any extra details you want to remember...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    borderSide: BorderSide(color: Color(0xFFD946A6), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please sign in first.')),
                    );
                    return;
                  }
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  await FirebaseService.logSymptom(
                    user.uid,
                    _selectedDate,
                    _selectedSymptoms.toList(),
                  );
                  final dateStr = DateFormat('MMM d').format(_selectedDate);
                  messenger.showSnackBar(
                    SnackBar(content: Text('Symptoms saved for $dateStr.')),
                  );
                  navigator.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD946A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
