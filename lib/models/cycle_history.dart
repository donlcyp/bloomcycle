import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CycleHistoryEntry {
  final String? id; // Firebase document ID
  final DateTime startDate;
  final int cycleLengthDays;
  final int periodLengthDays;

  CycleHistoryEntry({
    this.id,
    required this.startDate,
    required this.cycleLengthDays,
    required this.periodLengthDays,
  });

  /// Convert to JSON for Firebase storage
  Map<String, dynamic> toJson() {
    return {
      'cycleStart': startDate,
      'cycleLength': cycleLengthDays,
      'periodLength': periodLengthDays,
    };
  }

  /// Create from Firebase JSON
  factory CycleHistoryEntry.fromJson(Map<String, dynamic> json, {String? id}) {
    return CycleHistoryEntry(
      id: id,
      startDate: (json['cycleStart'] is DateTime)
          ? json['cycleStart'] as DateTime
          : DateTime.parse(json['cycleStart'] as String),
      cycleLengthDays: json['cycleLength'] as int? ?? 28,
      periodLengthDays: json['periodLength'] as int? ?? 5,
    );
  }

  /// Get all period days for this cycle entry
  List<DateTime> getPeriodDays() {
    final periodDays = <DateTime>[];
    for (int i = 0; i < periodLengthDays; i++) {
      periodDays.add(startDate.add(Duration(days: i)));
    }
    return periodDays;
  }
}

class CycleHistoryData {
  // In-memory cache of cycles
  static List<CycleHistoryEntry> recentCycles = [];
  static bool _isLoaded = false;

  /// Load cycles from Firebase for the current user
  static Future<void> loadCycles() async {
    if (_isLoaded) return; // Only load once per session

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      recentCycles = [];
      _isLoaded = true;
      return;
    }

    try {
      final cycles = await FirebaseService.getCycles(user.uid);
      recentCycles = cycles
          .map((json) => CycleHistoryEntry.fromJson(json, id: json['id'] as String?))
          .toList();
      _isLoaded = true;
    } catch (e) {
      // ignore: avoid_print
      print('Error loading cycles: $e');
      recentCycles = [];
      _isLoaded = true;
    }
  }

  /// Reload cycles from Firebase (force refresh)
  static Future<void> reloadCycles() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      recentCycles = [];
      return;
    }

    try {
      final cycles = await FirebaseService.getCycles(user.uid);
      recentCycles = cycles
          .map((json) => CycleHistoryEntry.fromJson(json, id: json['id'] as String?))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error reloading cycles: $e');
    }
  }

  /// Get all period days from all recorded cycles
  static List<DateTime> getAllPeriodDaysFromCycles() {
    final allPeriodDays = <DateTime>[];
    for (final cycle in recentCycles) {
      allPeriodDays.addAll(cycle.getPeriodDays());
    }
    return allPeriodDays;
  }

  /// Add a new cycle entry and save to Firebase
  static Future<void> addCycle(CycleHistoryEntry cycle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      recentCycles.insert(0, cycle);
      return;
    }

    try {
      await FirebaseService.saveCycleData(user.uid, cycle.toJson());
      recentCycles.insert(0, cycle);
    } catch (e) {
      // ignore: avoid_print
      print('Error adding cycle: $e');
      rethrow;
    }
  }

  /// Update an existing cycle at the given index and save to Firebase
  static Future<void> updateCycle(int index, CycleHistoryEntry cycle) async {
    if (index < 0 || index >= recentCycles.length) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      recentCycles[index] = cycle;
      return;
    }

    try {
      final oldCycle = recentCycles[index];
      await FirebaseService.saveCycleData(
        user.uid,
        {
          'id': oldCycle.id,
          ...cycle.toJson(),
        },
      );
      recentCycles[index] = cycle;
    } catch (e) {
      // ignore: avoid_print
      print('Error updating cycle: $e');
      rethrow;
    }
  }

  /// Remove a cycle at the given index and delete from Firebase
  static Future<void> removeCycle(int index) async {
    if (index < 0 || index >= recentCycles.length) return;

    final user = FirebaseAuth.instance.currentUser;
    final cycle = recentCycles[index];

    if (user != null && cycle.id != null && cycle.id!.isNotEmpty) {
      try {
        // Delete from Firebase
        await FirebaseService.deleteCycle(user.uid, cycle.id!);
      } catch (e) {
        // ignore: avoid_print
        print('Error deleting cycle: $e');
        rethrow;
      }
    }

    recentCycles.removeAt(index);
  }

  static int get averageCycleLength {
    if (recentCycles.isEmpty) return 0;
    final total = recentCycles.fold<int>(
      0,
      (sum, c) => sum + c.cycleLengthDays,
    );
    return (total / recentCycles.length).round();
  }

  static int get averagePeriodLength {
    if (recentCycles.isEmpty) return 0;
    final total = recentCycles.fold<int>(
      0,
      (sum, c) => sum + c.periodLengthDays,
    );
    return (total / recentCycles.length).round();
  }
}
