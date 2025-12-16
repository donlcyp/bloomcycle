import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import 'symptoms_log.dart';
import 'mood_log.dart';

class NotesLogPage extends StatefulWidget {
  const NotesLogPage({super.key});

  @override
  State<NotesLogPage> createState() => _NotesLogPageState();
}

class _NotesLogPageState extends State<NotesLogPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _selectedDate;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();

  // Selection states
  String? _loveSelection; // Protected or Unprotected
  String? _mucusSelection; // Sticky, Creamy, Egg-White, Watery
  int _pillDay = 1;
  final int _pillTotal = 21;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _weightController.dispose();
    _temperatureController.dispose();
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
            // Content
            Expanded(child: _buildContent()),
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
            onTap: _saveData,
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
        if (index == 1) {
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
          color: isSelected ? const Color(0xFFD6EAF8) : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.grey[700] : Colors.grey,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Love item
          _buildLoveItem(),
          // Mucus item
          _buildMucusItem(),
          // Pill item
          _buildPillItem(),
          // Weight and Temperature row
          _buildWeightTempRow(),
          // Notes text area
          _buildNotesArea(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoveItem() {
    return GestureDetector(
      onTap: () => _showLoveOptions(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Heart icon
            Icon(
              Icons.favorite_border,
              color: const Color(0xFFEC4899).withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(width: 16),
            // Checkbox circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _loveSelection != null
                      ? const Color(0xFFEC4899)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: _loveSelection != null
                    ? const Color(0xFFEC4899).withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: _loveSelection != null
                  ? const Icon(Icons.check, size: 18, color: Color(0xFFEC4899))
                  : null,
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                _loveSelection != null ? 'Love ($_loveSelection)' : 'Love',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _loveSelection != null
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            // Question mark icon
            Icon(
              Icons.help_outline,
              color: Colors.grey.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMucusItem() {
    return GestureDetector(
      onTap: () => _showMucusOptions(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Mucus icon (using a droplet-like icon)
            Icon(
              Icons.water_drop_outlined,
              color: const Color(0xFFEC4899).withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(width: 16),
            // Checkbox circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _mucusSelection != null
                      ? const Color(0xFFEC4899)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: _mucusSelection != null
                    ? const Color(0xFFEC4899).withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: _mucusSelection != null
                  ? const Icon(Icons.check, size: 18, color: Color(0xFFEC4899))
                  : null,
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                _mucusSelection != null ? 'Mucus ($_mucusSelection)' : 'Mucus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _mucusSelection != null
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillItem() {
    return GestureDetector(
      onTap: () => _showPillOptions(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Pill icon
            Icon(
              Icons.medication_outlined,
              color: const Color(0xFFEC4899).withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(width: 16),
            // Checkbox circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _pillDay > 1
                      ? const Color(0xFFEC4899)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: _pillDay > 1
                    ? const Color(0xFFEC4899).withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: _pillDay > 1
                  ? const Icon(Icons.check, size: 18, color: Color(0xFFEC4899))
                  : null,
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                'Pill ($_pillDay/$_pillTotal)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _pillDay > 1 ? FontWeight.w600 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTempRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          // Weight section
          Icon(
            Icons.monitor_weight_outlined,
            color: const Color(0xFFEC4899).withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'kg',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Temperature section
          Icon(
            Icons.thermostat_outlined,
            color: const Color(0xFFEC4899).withValues(alpha: 0.6),
            size: 32,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: TextField(
                controller: _temperatureController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '°C',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesArea() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(
              Icons.edit_outlined,
              color: const Color(0xFFEC4899).withValues(alpha: 0.6),
              size: 32,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Add notes...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ),
        ],
      ),
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
      setState(() => _selectedDate = picked);
    }
  }

  void _showLoveOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    'Choose type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFEC4899),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOptionItem('Protected', _loveSelection == 'Protected', () {
                setState(() => _loveSelection = 'Protected');
                Navigator.pop(context);
              }),
              _buildOptionItem(
                'Unprotected',
                _loveSelection == 'Unprotected',
                () {
                  setState(() => _loveSelection = 'Unprotected');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showMucusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  const Text(
                    'Choose type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEC4899),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFEC4899),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildOptionItem('Sticky', _mucusSelection == 'Sticky', () {
                setState(() => _mucusSelection = 'Sticky');
                Navigator.pop(context);
              }),
              _buildOptionItem('Creamy', _mucusSelection == 'Creamy', () {
                setState(() => _mucusSelection = 'Creamy');
                Navigator.pop(context);
              }),
              _buildOptionItem('Egg-White', _mucusSelection == 'Egg-White', () {
                setState(() => _mucusSelection = 'Egg-White');
                Navigator.pop(context);
              }),
              _buildOptionItem('Watery', _mucusSelection == 'Watery', () {
                setState(() => _mucusSelection = 'Watery');
                Navigator.pop(context);
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showPillOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const Text(
                        'Pill Day',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFEC4899),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (_pillDay > 1) {
                            setModalState(() => _pillDay--);
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xFFEC4899),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        '$_pillDay / $_pillTotal',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          if (_pillDay < _pillTotal) {
                            setModalState(() => _pillDay++);
                            setState(() {});
                          }
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFFEC4899),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEC4899),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOptionItem(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFEC4899)
                      : Colors.grey.withValues(alpha: 0.4),
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFEC4899).withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 18, color: Color(0xFFEC4899))
                  : null,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Build the note content from all fields
    final List<String> noteItems = [];

    if (_loveSelection != null) {
      noteItems.add('Love: $_loveSelection');
    }
    if (_mucusSelection != null) {
      noteItems.add('Mucus: $_mucusSelection');
    }
    if (_pillDay > 1) {
      noteItems.add('Pill: Day $_pillDay/$_pillTotal');
    }
    if (_weightController.text.trim().isNotEmpty) {
      noteItems.add('Weight: ${_weightController.text.trim()} kg');
    }
    if (_temperatureController.text.trim().isNotEmpty) {
      noteItems.add('Temperature: ${_temperatureController.text.trim()}°C');
    }
    if (_notesController.text.trim().isNotEmpty) {
      noteItems.add('Notes: ${_notesController.text.trim()}');
    }

    if (noteItems.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please add at least one entry'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final noteContent = noteItems.join('\n');

    await FirebaseService.saveNote(user.uid, _selectedDate, noteContent);

    final dateStr = DateFormat('MMM d').format(_selectedDate);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Notes saved for $dateStr'),
        backgroundColor: const Color(0xFFEC4899),
      ),
    );
    navigator.pop();
  }
}
