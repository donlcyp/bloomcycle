import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../services/cycle_predictions.dart';
import '../../state/user_state.dart';
import 'notes_log.dart';
import 'mood_log.dart';

class SymptomsLogPage extends StatefulWidget {
  const SymptomsLogPage({super.key});

  @override
  State<SymptomsLogPage> createState() => _SymptomsLogPageState();
}

class _SymptomsLogPageState extends State<SymptomsLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  final Set<String> _selectedSymptoms = {};

  // Cycle data for predictions
  DateTime? _cycleStartDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  CyclePhase _currentPhase = CyclePhase.unknown;
  List<String> _predictedSymptoms = [];

  // Symptom data with icons
  final List<SymptomItem> _allSymptoms = [
    SymptomItem('Achy', Icons.flash_on_outlined),
    SymptomItem('Acne', Icons.bubble_chart_outlined),
    SymptomItem('Bloated', Icons.chat_bubble_outline),
    SymptomItem('Blood Pressure High', Icons.favorite),
    SymptomItem('Blood Pressure Low', Icons.favorite_border),
    SymptomItem('Breast Tenderness', Icons.spa_outlined),
    SymptomItem('Constipation', Icons.receipt_long_outlined),
    SymptomItem('Cramps', Icons.electric_bolt_outlined),
    SymptomItem('Craving', Icons.fastfood_outlined),
    SymptomItem('Diarrhea', Icons.receipt_outlined),
    SymptomItem('Dizzy', Icons.motion_photos_on_outlined),
    SymptomItem('Fever', Icons.thermostat_outlined),
    SymptomItem('Gas', Icons.cloud_outlined),
    SymptomItem('Headache', Icons.psychology_outlined),
    SymptomItem('Insomnia', Icons.visibility_outlined),
    SymptomItem('Itch', Icons.back_hand_outlined),
    SymptomItem('Mucus', Icons.water_drop_outlined),
    SymptomItem('Nausea', Icons.sick_outlined),
    SymptomItem('PMS', Icons.cake_outlined),
    SymptomItem('Spotting', Icons.opacity),
    SymptomItem('Sweaty', Icons.water_drop),
    SymptomItem('Swelling', Icons.pan_tool_outlined),
    SymptomItem('Tired', Icons.bedtime_outlined),
    SymptomItem('Weak', Icons.battery_2_bar_outlined),
    SymptomItem('Weight Gain', Icons.speed),
    SymptomItem('Weight Loss', Icons.speed_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _loadCycleData();
  }

  Future<void> _loadCycleData() async {
    final settings = UserState.currentUser.settings.cycleSettings;
    _cycleLength = settings.cycleLength;
    _periodLength = settings.periodLength;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final latest = await FirebaseService.getCycleData(user.uid);
      if (!mounted) return;
      if (latest == null) return;

      final start = latest['cycleStart'] as DateTime?;
      final storedCycleLength = latest['cycleLength'] as int?;
      final storedPeriodLength = latest['periodLength'] as int?;

      setState(() {
        if (start != null) {
          _cycleStartDate = DateTime(start.year, start.month, start.day);
        }
        _cycleLength = storedCycleLength ?? _cycleLength;
        _periodLength = storedPeriodLength ?? _periodLength;
        _updatePredictions();
      });
    } catch (_) {
      // Ignore errors
    }
  }

  void _updatePredictions() {
    if (_cycleStartDate == null) {
      _currentPhase = CyclePhase.unknown;
      _predictedSymptoms = [];
      return;
    }

    final today = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final start = DateTime(
      _cycleStartDate!.year,
      _cycleStartDate!.month,
      _cycleStartDate!.day,
    );
    final diffDays = today.difference(start).inDays;

    if (diffDays < 0 || diffDays >= _cycleLength) {
      _currentPhase = CyclePhase.unknown;
      _predictedSymptoms = [];
      return;
    }

    final cycleDay = (diffDays % _cycleLength) + 1;
    _currentPhase = CyclePredictions.getPhase(
      cycleDay,
      _cycleLength,
      _periodLength,
    );
    _predictedSymptoms = CyclePredictions.getPredictedSymptoms(_currentPhase);
  }

  List<SymptomItem> get _sortedSymptoms {
    // Put predicted symptoms at the top
    final predicted = <SymptomItem>[];
    final others = <SymptomItem>[];

    for (final symptom in _allSymptoms) {
      if (_predictedSymptoms.contains(symptom.name)) {
        predicted.add(
          SymptomItem(symptom.name, symptom.icon, isPrediction: true),
        );
      } else {
        others.add(symptom);
      }
    }

    return [...predicted, ...others];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            // Tab Bar
            _buildTabBar(),
            // Symptom List
            Expanded(child: _buildSymptomList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.chevron_left,
              color: Color(0xFFEC4899),
              size: 32,
            ),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Row(
              children: [
                Text(
                  DateFormat('d').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF64B5F6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _saveSymptoms,
            child: const Icon(Icons.check, color: Color(0xFFEC4899), size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, Icons.menu_book_outlined, 'Notes')),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          Expanded(child: _buildTabItem(1, Icons.auto_awesome, 'Symptoms')),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildTabItem(
              2,
              Icons.sentiment_satisfied_outlined,
              'Moods',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate to Notes
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const NotesLogPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else if (index == 2) {
          // Navigate to Moods
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const MoodLogPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9C4) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.grey[700] : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSymptomList() {
    final symptoms = _sortedSymptoms;

    return Column(
      children: [
        // Phase indicator header
        if (_currentPhase != CyclePhase.unknown)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(CyclePredictions.getPhaseColor(_currentPhase)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEC4899).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFFEC4899),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${CyclePredictions.getPhaseName(_currentPhase)} Phase',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                      Text(
                        CyclePredictions.getPhaseDescriptionWithDays(_currentPhase, _cycleLength, _periodLength),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (_predictedSymptoms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Predicted symptoms for this phase are highlighted',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Symptom list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: symptoms.length,
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              final isSelected = _selectedSymptoms.contains(symptom.name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(symptom.name);
                    } else {
                      _selectedSymptoms.add(symptom.name);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFF9C4)
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Symptom icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            symptom.icon,
                            size: 24,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Symptom name and prediction label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              symptom.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            if (symptom.isPrediction)
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Common in ${CyclePredictions.getPhaseName(_currentPhase)} phase',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.amber[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Checkmark if selected
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFFB300),
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC4899),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updatePredictions();
      });
    }
  }

  Future<void> _saveSymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
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
    final symptomCount = _selectedSymptoms.length;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$symptomCount symptom${symptomCount > 1 ? 's' : ''} saved for $dateStr',
        ),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
    navigator.pop();
  }
}

class SymptomItem {
  final String name;
  final IconData icon;
  final bool isPrediction;

  SymptomItem(this.name, this.icon, {this.isPrediction = false});
}
