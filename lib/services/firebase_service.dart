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

  static Future<void> saveCycleData(
    String uid,
    Map<String, dynamic> cycleData,
  ) async {
    final cycles = _cyclesRef(uid);
    final cycleId = (cycleData['id'] ?? cycleData['cycleId']) as String?;
    final payload = _serialize({
      ...cycleData,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (cycleId != null && cycleId.isNotEmpty) {
      await cycles.doc(cycleId).set(payload, SetOptions(merge: true));
    } else {
      await cycles.add({...payload, 'createdAt': FieldValue.serverTimestamp()});
    }
  }

  /// Returns the latest cycle entry for the user, if available.
  static Future<Map<String, dynamic>?> getCycleData(String uid) async {
    final snapshot = await _cyclesRef(
      uid,
    ).orderBy('cycleStart', descending: true).limit(1).get();

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
