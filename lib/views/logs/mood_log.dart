import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../services/cycle_predictions.dart';
import '../../state/user_state.dart';
import 'notes_log.dart';
import 'symptoms_log.dart';

class MoodLogPage extends StatefulWidget {
  const MoodLogPage({super.key});

  @override
  State<MoodLogPage> createState() => _MoodLogPageState();
}

class _MoodLogPageState extends State<MoodLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  final Set<String> _selectedMoods = {};

  // Cycle data for predictions
  DateTime? _cycleStartDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  CyclePhase _currentPhase = CyclePhase.unknown;
  List<String> _predictedMoods = [];

  // Mood data with emoji-style icons
  final List<MoodItem> _allMoods = [
    MoodItem('Angry', '😠'),
    MoodItem('Anxious', '😰'),
    MoodItem('Blue', '😢'),
    MoodItem('Calm', '😌'),
    MoodItem('Confident', '😎'),
    MoodItem('Confused', '😕'),
    MoodItem('Cranky', '😤'),
    MoodItem('Craving', '🤤'),
    MoodItem('Depressed', '😞'),
    MoodItem('Emotional', '🥺'),
    MoodItem('Excited', '😃'),
    MoodItem('Forgetful', '🤔'),
    MoodItem('Frustrated', '😩'),
    MoodItem('Happy', '😊'),
    MoodItem('Irritated', '😒'),
    MoodItem('Jealous', '😒'),
    MoodItem('Lazy', '😴'),
    MoodItem('Naughty', '😏'),
    MoodItem('Peaceful', '🧘'),
    MoodItem('Romantic', '🥰'),
    MoodItem('Sad', '😢'),
    MoodItem('Sexy', '😘'),
    MoodItem('Sleepy', '😪'),
    MoodItem('Stressed', '😫'),
    MoodItem('Tired', '😴'),
    MoodItem('Unfocused', '😵'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
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
      _predictedMoods = [];
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
      _predictedMoods = [];
      return;
    }

    final cycleDay = (diffDays % _cycleLength) + 1;
    _currentPhase = CyclePredictions.getPhase(
      cycleDay,
      _cycleLength,
      _periodLength,
    );
    _predictedMoods = CyclePredictions.getPredictedMoods(_currentPhase);
  }

  List<MoodItem> get _sortedMoods {
    // Put predicted moods at the top
    final predicted = <MoodItem>[];
    final others = <MoodItem>[];

    for (final mood in _allMoods) {
      if (_predictedMoods.contains(mood.name)) {
        predicted.add(MoodItem(mood.name, mood.emoji, isPrediction: true));
      } else {
        others.add(mood);
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
            // Mood List
            Expanded(child: _buildMoodList()),
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
            onTap: _saveMoods,
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
        } else if (index == 1) {
          // Navigate to Symptoms
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const SymptomsLogPage(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFBE9E7) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFEC4899) : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildMoodList() {
    final moods = _sortedMoods;

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
        if (_predictedMoods.isNotEmpty)
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
                    'Predicted moods for this phase are highlighted',
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
        // Mood list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              final isSelected = _selectedMoods.contains(mood.name);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMoods.remove(mood.name);
                    } else {
                      _selectedMoods.add(mood.name);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFCE4EC)
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
                      // Mood face icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Mood name and prediction label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            if (mood.isPrediction)
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: Colors.amber[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Predicted for ${CyclePredictions.getPhaseName(_currentPhase)} phase',
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
                          color: Color(0xFFEC4899),
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

  Future<void> _saveMoods() async {
    if (_selectedMoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one mood'),
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

    // Save each selected mood
    for (final moodName in _selectedMoods) {
      await FirebaseService.logMood(
        user.uid,
        _selectedDate,
        moodName,
        3, // Default intensity
      );
    }

    final dateStr = DateFormat('MMM d').format(_selectedDate);
    final moodCount = _selectedMoods.length;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$moodCount mood${moodCount > 1 ? 's' : ''} saved for $dateStr',
        ),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
    navigator.pop();
  }
}

class MoodItem {
  final String name;
  final String emoji;
  final bool isPrediction;

  MoodItem(this.name, this.emoji, {this.isPrediction = false});
}
