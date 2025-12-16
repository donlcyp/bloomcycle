import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

import '../firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static bool _isInitialized = false;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Initialize Firebase and configure Firestore.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Enable local persistence & timestamps in snapshots (default true but explicit for clarity).
      _firestore.settings = const Settings(persistenceEnabled: true);

      _isInitialized = true;
      // ignore: avoid_print
      print('✓ Firebase initialized successfully');
    } catch (e) {
      // Ignore duplicate app error - Firebase may already be initialized
      if (e.toString().contains('duplicate-app')) {
        _isInitialized = true;
        // ignore: avoid_print
        print('✓ Firebase already initialized');
      } else {
        // ignore: avoid_print
        print('✗ Firebase initialization error: $e');
        rethrow;
      }
    }
  }

  // region: User operations -------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _userCollection() =>
      _firestore.collection('users');

  static Future<void> createUser(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    final docRef = _userCollection().doc(uid);

    final dataToPersist = _serialize({
      ...userData,
      'uid': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await docRef.set({
      ...dataToPersist,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _userCollection().doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    data['id'] = doc.id;
    return _deserialize(data);
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final docRef = _userCollection().doc(uid);
    await docRef.set(
      _serialize({...data, 'updatedAt': FieldValue.serverTimestamp()}),
      SetOptions(merge: true),
    );
  }

  static Future<void> deleteUser(String uid) async {
    await _userCollection().doc(uid).delete();
  }

  // endregion

  // region: Cycle data ------------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _cyclesRef(String uid) =>
      _userCollection().doc(uid).collection('cycles');

  /// Reference to the current active cycle document
  static DocumentReference<Map<String, dynamic>> _currentCycleRef(String uid) =>
      _cyclesRef(uid).doc('current');

  static Future<void> saveCycleData(
    String uid,
    Map<String, dynamic> cycleData,
  ) async {
    final payload = _serialize({
      ...cycleData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Always save to the "current" document for the active cycle
    await _currentCycleRef(uid).set(payload, SetOptions(merge: true));
  }

  /// Returns the current active cycle for the user, if available.
  static Future<Map<String, dynamic>?> getCycleData(String uid) async {
    // First try to get the "current" document
    final currentDoc = await _currentCycleRef(uid).get();
    if (currentDoc.exists) {
      final data = currentDoc.data()!;
      data['id'] = currentDoc.id;
      return _deserialize(data);
    }
    
    // Fallback: check for legacy documents (ordered by updatedAt to get most recent)
    final snapshot = await _cyclesRef(uid)
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    final data = doc.data();
    data['id'] = doc.id;
    return _deserialize(data);
  }

  static Future<List<Map<String, dynamic>>> getCycles(String uid) async {
    final snapshot = await _cyclesRef(uid)
        .orderBy('cycleStart', descending: true)
        .limit(24)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _deserialize(data) as Map<String, dynamic>;
    }).toList();
  }

  // endregion

  // region: Symptoms --------------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _symptomsRef(String uid) =>
      _userCollection().doc(uid).collection('symptoms');

  static Future<void> logSymptom(
    String uid,
    DateTime date,
    List<String> symptoms,
  ) async {
    final symptomId = DateFormat('yyyy-MM-dd').format(date);
    await _symptomsRef(uid)
        .doc(symptomId)
        .set(
          _serialize({
            'date': date,
            'symptoms': symptoms,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
  }

  static Future<List<Map<String, dynamic>>> getSymptoms(String uid) async {
    final snapshot = await _symptomsRef(
      uid,
    ).orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _deserialize(data) as Map<String, dynamic>;
    }).toList();
  }

  // endregion

  // region: Notes -----------------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _notesRef(String uid) =>
      _userCollection().doc(uid).collection('notes');

  static Future<void> saveNote(
    String uid,
    DateTime date,
    String noteText,
  ) async {
    final noteId = DateFormat('yyyy-MM-dd').format(date);
    await _notesRef(uid)
        .doc(noteId)
        .set(
          _serialize({
            'date': date,
            'note': noteText,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
  }

  static Future<List<Map<String, dynamic>>> getNotes(String uid) async {
    final snapshot = await _notesRef(
      uid,
    ).orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _deserialize(data) as Map<String, dynamic>;
    }).toList();
  }

  // endregion

  // region: Mood tracking ---------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _moodsRef(String uid) =>
      _userCollection().doc(uid).collection('moods');

  static Future<void> logMood(
    String uid,
    DateTime date,
    String mood,
    int intensity,
  ) async {
    final moodId = DateFormat('yyyy-MM-dd').format(date);
    await _moodsRef(uid)
        .doc(moodId)
        .set(
          _serialize({
            'date': date,
            'mood': mood,
            'intensity': intensity,
            'updatedAt': FieldValue.serverTimestamp(),
          }),
          SetOptions(merge: true),
        );
  }

  static Future<List<Map<String, dynamic>>> getMoodHistory(String uid) async {
    final snapshot = await _moodsRef(
      uid,
    ).orderBy('date', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _deserialize(data) as Map<String, dynamic>;
    }).toList();
  }

  // endregion

  // region: Health tips -----------------------------------------------------

  static CollectionReference<Map<String, dynamic>> _tipsRef() =>
      _firestore.collection('healthTips');

  static Future<List<Map<String, dynamic>>> getHealthTips() async {
    final snapshot = await _tipsRef().get();

    if (snapshot.docs.isEmpty) {
      // Fallback tips if collection is empty.
      return const [
        {
          'title': 'Stay hydrated',
          'content':
              'Drink at least 8 glasses of water daily to support hormonal balance.',
        },
        {
          'title': 'Prioritise rest',
          'content':
              'Adequate sleep helps regulate your cycle and improves mood tracking accuracy.',
        },
      ];
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return _deserialize(data) as Map<String, dynamic>;
    }).toList();
  }

  // endregion

  // region: Admin operations ------------------------------------------------

  /// Get all users for admin dashboard (falls back to current user if no permission)
  static Future<List<Map<String, dynamic>>> getAllUsers({String? currentUserId}) async {
    try {
      final snapshot = await _userCollection()
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _deserialize(data) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Admin access denied, falling back to current user: $e');
      // Fall back to current user only
      if (currentUserId != null) {
        final userData = await getUser(currentUserId);
        if (userData != null) return [userData];
      }
      return [];
    }
  }

  /// Get user count statistics
  static Future<Map<String, int>> getUserStats({String? currentUserId}) async {
    try {
      final allUsers = await _userCollection().get();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekAgo = now.subtract(const Duration(days: 7));
      
      int totalUsers = allUsers.docs.length;
      int activeToday = 0;
      int newThisWeek = 0;
      
      for (var doc in allUsers.docs) {
        final data = doc.data();
        
        // Check if user was active today (updatedAt is today)
        if (data['updatedAt'] != null) {
          final updatedAt = data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate()
              : data['updatedAt'] as DateTime?;
          if (updatedAt != null && updatedAt.isAfter(todayStart)) {
            activeToday++;
          }
        }
        
        // Check if user registered this week
        if (data['createdAt'] != null) {
          final createdAt = data['createdAt'] is Timestamp 
              ? (data['createdAt'] as Timestamp).toDate()
              : data['createdAt'] as DateTime?;
          if (createdAt != null && createdAt.isAfter(weekAgo)) {
            newThisWeek++;
          }
        }
      }
      
      return {
        'totalUsers': totalUsers,
        'activeToday': activeToday,
        'newThisWeek': newThisWeek,
      };
    } catch (e) {
      print('Error fetching user stats: $e');
      // Fall back to current user stats
      if (currentUserId != null) {
        final userData = await getUser(currentUserId);
        if (userData != null) {
          return {
            'totalUsers': 1,
            'activeToday': 1,
            'newThisWeek': 1,
          };
        }
      }
      return {
        'totalUsers': 0,
        'activeToday': 0,
        'newThisWeek': 0,
      };
    }
  }

  /// Get recent users (last N registrations)
  static Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 10, String? currentUserId}) async {
    try {
      final snapshot = await _userCollection()
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _deserialize(data) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error fetching recent users: $e');
      // Fall back to current user
      if (currentUserId != null) {
        final userData = await getUser(currentUserId);
        if (userData != null) return [userData];
      }
      return [];
    }
  }

  /// Get daily active users for the last N days
  static Future<Map<String, int>> getDailyActiveUsers({int days = 7, String? currentUserId}) async {
    final result = <String, int>{};
    final now = DateTime.now();
    
    // Initialize all days with 0
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date); // Mon, Tue, etc.
      result[dayName] = 0;
    }
    
    try {
      // Get all users and count by updatedAt date
      final snapshot = await _userCollection().get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['updatedAt'] != null) {
          final updatedAt = data['updatedAt'] is Timestamp 
              ? (data['updatedAt'] as Timestamp).toDate()
              : data['updatedAt'] as DateTime?;
          
          if (updatedAt != null) {
            final daysAgo = now.difference(updatedAt).inDays;
            if (daysAgo < days) {
              final dayName = DateFormat('E').format(updatedAt);
              result[dayName] = (result[dayName] ?? 0) + 1;
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching daily active users: $e');
      // Fall back - show current user's activity for today
      if (currentUserId != null) {
        final todayName = DateFormat('E').format(now);
        result[todayName] = 1;
      }
    }
    
    return result;
  }

  /// Get total data records count (cycles, symptoms, notes, moods)
  static Future<int> getTotalDataRecords({String? currentUserId}) async {
    // If we have current user ID, get their data directly (most reliable)
    if (currentUserId != null) {
      try {
        int total = 0;
        
        final cycles = await _cyclesRef(currentUserId).get();
        total += cycles.docs.length;
        
        final symptoms = await _symptomsRef(currentUserId).get();
        total += symptoms.docs.length;
        
        final notes = await _notesRef(currentUserId).get();
        total += notes.docs.length;
        
        final moods = await _moodsRef(currentUserId).get();
        total += moods.docs.length;
        
        return total;
      } catch (e) {
        print('Error getting current user data records: $e');
        return 0;
      }
    }
    
    // Fallback: try to get all users' data (admin mode)
    try {
      int total = 0;
      
      final users = await _userCollection().get();
      
      for (var userDoc in users.docs) {
        final uid = userDoc.id;
        
        try {
          final cycles = await _cyclesRef(uid).get();
          total += cycles.docs.length;
          
          final symptoms = await _symptomsRef(uid).get();
          total += symptoms.docs.length;
          
          final notes = await _notesRef(uid).get();
          total += notes.docs.length;
          
          final moods = await _moodsRef(uid).get();
          total += moods.docs.length;
        } catch (_) {}
      }
      
      return total;
    } catch (e) {
      print('Error fetching total data records: $e');
      return 0;
    }
  }

  /// Log admin activity
  static Future<void> logAdminActivity(String action) async {
    try {
      await _firestore.collection('adminLogs').add({
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin activity: $e');
    }
  }

  /// Get recent admin activities
  static Future<List<Map<String, dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('adminLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return _deserialize(data) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('Error fetching recent activities: $e');
      return [];
    }
  }

  /// Delete a user and all their data
  static Future<void> deleteUserAndData(String uid) async {
    try {
      // Delete subcollections first
      final cycles = await _cyclesRef(uid).get();
      for (var doc in cycles.docs) {
        await doc.reference.delete();
      }
      
      final symptoms = await _symptomsRef(uid).get();
      for (var doc in symptoms.docs) {
        await doc.reference.delete();
      }
      
      final notes = await _notesRef(uid).get();
      for (var doc in notes.docs) {
        await doc.reference.delete();
      }
      
      final moods = await _moodsRef(uid).get();
      for (var doc in moods.docs) {
        await doc.reference.delete();
      }
      
      // Finally delete the user document
      await _userCollection().doc(uid).delete();
      
      // Log the activity
      await logAdminActivity('User deleted: $uid');
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  // endregion

  // region: Helpers ---------------------------------------------------------

  static Map<String, dynamic> _serialize(Map<String, dynamic> data) {
    return data.map((key, value) => MapEntry(key, _serializeValue(value)));
  }

  static dynamic _serializeValue(dynamic value) {
    if (value is DateTime) {
      return Timestamp.fromDate(value.toUtc());
    }
    if (value is Timestamp) {
      return value;
    }
    if (value is FieldValue) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      return _serialize(value);
    }
    if (value is Iterable) {
      return value.map(_serializeValue).toList();
    }
    return value;
  }

  static dynamic _deserialize(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is Map<String, dynamic>) {
      return value.map(
        (key, innerValue) => MapEntry(key, _deserialize(innerValue)),
      );
    }
    if (value is Iterable) {
      return value.map(_deserialize).toList();
    }
    return value;
  }

  // endregion
}
