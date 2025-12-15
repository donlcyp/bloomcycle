import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

bool _googleSignInInitialized = false;
Future<void>? _initializationFuture;

Future<void> ensureGoogleSignInInitialized() {
  if (_googleSignInInitialized) {
    return Future.value();
  }

  final existingFuture = _initializationFuture;
  if (existingFuture != null) {
    return existingFuture;
  }

  final future = GoogleSignIn.instance
      .initialize()
      .then((_) {
        _googleSignInInitialized = true;
      })
      .whenComplete(() {
        _initializationFuture = null;
      });

  _initializationFuture = future;
  return future;
}

class GoogleSignInResult {
  const GoogleSignInResult({required this.userCredential, this.googleAccount});

  final UserCredential userCredential;
  final GoogleSignInAccount? googleAccount;
}

Future<GoogleSignInResult?> signInWithGoogleCredential({
  List<String> scopeHint = const [],
}) async {
  if (kIsWeb) {
    final GoogleAuthProvider provider = GoogleAuthProvider();
    if (scopeHint.isNotEmpty) {
      for (final scope in scopeHint) {
        provider.addScope(scope);
      }
    }
    final credential = await FirebaseAuth.instance.signInWithPopup(provider);
    return GoogleSignInResult(userCredential: credential);
  }

  await ensureGoogleSignInInitialized();
  await GoogleSignIn.instance.signOut();

  GoogleSignInAccount account;
  try {
    account = await GoogleSignIn.instance.authenticate(scopeHint: scopeHint);
  } on GoogleSignInException catch (e) {
    developer.log(
      'GoogleSignInException: code=${e.code}',
      name: 'google_sign_in',
    );
    if (e.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    rethrow;
  } catch (e) {
    developer.log(
      'Unexpected exception during Google sign-in: $e',
      name: 'google_sign_in',
    );
    rethrow;
  }
  final GoogleSignInAuthentication authData = account.authentication;
  final String? idToken = authData.idToken;

  if (idToken == null) {
    throw StateError('Missing Google ID token.');
  }

  final OAuthCredential credential = GoogleAuthProvider.credential(
    idToken: idToken,
  );
  final userCredential = await FirebaseAuth.instance.signInWithCredential(
    credential,
  );
  return GoogleSignInResult(
    userCredential: userCredential,
    googleAccount: account,
  );
}

Future<void> signOutGoogleClient() async {
  if (kIsWeb) {
    await FirebaseAuth.instance.signOut();
    return;
  }
  await GoogleSignIn.instance.signOut();
}
