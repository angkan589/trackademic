import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _database => FirebaseFirestore.instance;

  FirebaseFunctions get _functions {
    return FirebaseFunctions.instanceFor(region: 'asia-south1');
  }

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }

  Stream<User?> get userChanges {
    return _auth.userChanges();
  }

  User? get currentUser => _auth.currentUser;

  Future<AppUserProfile> register({
    required String displayName,
    required String email,
    required String institutionId,
    required String password,
  }) async {
    try {
      await _functions.httpsCallable('registerWithInvite').call({
        'displayName': displayName.trim(),
        'email': email.trim().toLowerCase(),
        'institutionId': institutionId.trim().toUpperCase(),
        'password': password,
      });

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw const AuthServiceException(
          'The account was created, but sign-in failed.',
        );
      }

      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      return loadCurrentProfile();
    } on FirebaseFunctionsException catch (error) {
      throw AuthServiceException(
        error.message ?? 'Registration failed. Please try again.',
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  Future<AppUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      return loadCurrentProfile();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    } on FirebaseException catch (error) {
      throw AuthServiceException(
        error.message ?? 'Your profile could not be loaded.',
      );
    }
  }

  Future<AppUserProfile> loadCurrentProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const AuthServiceException('You are not signed in.');
    }

    final document = await _database.collection('users').doc(user.uid).get();
    final data = document.data();

    if (!document.exists || data == null) {
      throw const AuthServiceException(
        'No Trackademic profile exists for this account.',
      );
    }

    final profile = AppUserProfile.fromMap(user.uid, data);

    if (!profile.isActive) {
      await signOut();

      throw const AuthServiceException('This account has been disabled.');
    }

    if (profile.role != 'student' && profile.role != 'teacher') {
      await signOut();

      throw const AuthServiceException('This account has an invalid role.');
    }

    return profile;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw const AuthServiceException('You are not signed in.');
    }

    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_authErrorMessage(error));
    }
  }

  Future<bool> refreshEmailVerification() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> signOut() {
    return _auth.signOut();
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'The email or password is incorrect.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      default:
        return error.message ?? 'Authentication failed.';
    }
  }
}

class AppUserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String institutionId;
  final String role;
  final bool isActive;
  final String? department;
  final String? batch;
  final String? section;
  final String? semester;

  const AppUserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.institutionId,
    required this.role,
    required this.isActive,
    this.department,
    this.batch,
    this.section,
    this.semester,
  });

  factory AppUserProfile.fromMap(String uid, Map<String, dynamic> data) {
    return AppUserProfile(
      uid: uid,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      institutionId: data['institutionId'] as String? ?? '',
      role: data['role'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? false,
      department: data['department'] as String?,
      batch: data['batch'] as String?,
      section: data['section'] as String?,
      semester: data['semester'] as String?,
    );
  }
}

class AuthServiceException implements Exception {
  final String message;

  const AuthServiceException(this.message);

  @override
  String toString() => message;
}
