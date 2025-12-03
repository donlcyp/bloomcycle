import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase/firebase_option.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  static late FirebaseFirestore _firestore;
  static bool _isInitialized = false;

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  // Initialize Firebase
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.android,
      );
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      print('✓ Firebase initialized successfully');
    } catch (e) {
      print('✗ Firebase initialization error: $e');
      rethrow;
    }
  }

  // Get Firestore instance
  static FirebaseFirestore get firestore {
    if (!_isInitialized) {
      throw Exception('Firebase not initialized. Call initialize() first.');
    }
    return _firestore;
  }

  // User Operations
  static Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      await firestore.collection('users').doc(uid).set(userData);
      print('✓ User created: $uid');
    } catch (e) {
      print('✗ Error creating user: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('✗ Error fetching user: $e');
      return null;
    }
  }

  static Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await firestore.collection('users').doc(uid).update(data);
      print('✓ User updated: $uid');
    } catch (e) {
      print('✗ Error updating user: $e');
      rethrow;
    }
  }

  // Cycle Data Operations
  static Future<void> saveCycleData(String uid, Map<String, dynamic> cycleData) async {
    try {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('cycle_data')
          .doc('current')
          .set(cycleData);
      print('✓ Cycle data saved for user: $uid');
    } catch (e) {
      print('✗ Error saving cycle data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getCycleData(String uid) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('cycle_data')
          .doc('current')
          .get();
      return doc.data();
    } catch (e) {
      print('✗ Error fetching cycle data: $e');
      return null;
    }
  }

  // Symptoms Logging
  static Future<void> logSymptom(
    String uid,
    DateTime date,
    List<String> symptoms,
  ) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await firestore
          .collection('users')
          .doc(uid)
          .collection('symptoms')
          .doc(dateStr)
          .set({
        'date': date,
        'symptoms': symptoms,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✓ Symptom logged for $dateStr');
    } catch (e) {
      print('✗ Error logging symptom: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getSymptoms(String uid) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('symptoms')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('✗ Error fetching symptoms: $e');
      return [];
    }
  }

  // Notes Operations
  static Future<void> saveNote(
    String uid,
    DateTime date,
    String noteText,
  ) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(dateStr)
          .set({
        'date': date,
        'text': noteText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✓ Note saved for $dateStr');
    } catch (e) {
      print('✗ Error saving note: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getNotes(String uid) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('✗ Error fetching notes: $e');
      return [];
    }
  }

  // Mood Tracking
  static Future<void> logMood(
    String uid,
    DateTime date,
    String mood,
    int intensity,
  ) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      await firestore
          .collection('users')
          .doc(uid)
          .collection('mood')
          .doc(dateStr)
          .set({
        'date': date,
        'mood': mood,
        'intensity': intensity,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✓ Mood logged for $dateStr');
    } catch (e) {
      print('✗ Error logging mood: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getMoodHistory(String uid) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('mood')
          .orderBy('date', descending: true)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('✗ Error fetching mood history: $e');
      return [];
    }
  }

  // Health Tips & Insights
  static Future<List<Map<String, dynamic>>> getHealthTips() async {
    try {
      final snapshot = await firestore
          .collection('health_tips')
          .orderBy('created_at', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('✗ Error fetching health tips: $e');
      return [];
    }
  }

  // Delete operations
  static Future<void> deleteUser(String uid) async {
    try {
      await firestore.collection('users').doc(uid).delete();
      print('✓ User deleted: $uid');
    } catch (e) {
      print('✗ Error deleting user: $e');
      rethrow;
    }
  }
}
