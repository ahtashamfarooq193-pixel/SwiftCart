import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isAdmin = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        _isAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _isAdmin = data?['isAdmin'] == true;
      } else {
        _isAdmin = false;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _isAdmin = false;
    }
    notifyListeners();
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Create User in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // 2. Save additional details in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'isAdmin': false, // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getAuthErrorMessage(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await fetchUserData(credential.user!.uid);
      }
      
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getAuthErrorMessage(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return 'Sign in cancelled'; // User cancelled
      }

      // 2. Obtain Auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Sign in to Firebase Auth
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 4. Save/Update user data in Firestore
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName ?? 'Google User',
            'email': user.email,
            'phone': user.phoneNumber ?? '',
            'gender': 'Not Specified',
            'isAdmin': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await fetchUserData(user.uid);
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getAuthErrorMessage(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google Sign-In Error: $e');
      
      final errorStr = e.toString();
      if (errorStr.contains('12500') || errorStr.contains('10')) {
        return 'Google Sign-In Failed (Code 10/12500). Please check if SHA-1 is added correctly in Firebase Console and Support Email is set.';
      }
      
      return 'Google Sign-In nakam raha.';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getAuthErrorMessage(e);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An unexpected error occurred. Please try again.';
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email pehle se istemal mein hai.';
      case 'invalid-email':
        return 'Email durust nahi hai.';
      case 'weak-password':
        return 'Password kam az kam 6 characters ka hona chahiye.';
      case 'user-not-found':
      case 'invalid-credential': // Firebase sometimes returns this for both
        return 'Email not registered';
      case 'wrong-password':
        return 'Incorrect Password';
      case 'network-request-failed':
        return 'Internet connection ka masla hai.';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}
