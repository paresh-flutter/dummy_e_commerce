import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_models;
import 'firestore_service.dart';
import 'user_data_manager.dart';

/// Service responsible for handling all authentication related operations
class AuthenticationService {
  final FirebaseAuth _firebaseAuth;
  final FirestoreService _firestoreService;
  final UserDataManager _userDataManager;

  /// Creates an instance of [AuthenticationService]
  AuthenticationService({
    FirebaseAuth? firebaseAuth,
    FirestoreService? firestoreService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestoreService = firestoreService ?? FirestoreService(),
        _userDataManager = UserDataManager();

  /// Get the current authenticated user
  Future<app_models.UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return _userFromFirebaseUser(user);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Sign in with email and password
  Future<app_models.UserModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User not found');
      }
      
      return _userFromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
      ]);
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  /// Register a new user with email and password
  Future<app_models.UserModel> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user');
      }

      // Update user profile with display name
      await userCredential.user?.updateDisplayName(name.trim());
      await userCredential.user?.reload();

      // Get the updated user
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('Failed to get user after registration');
      }

      // Create comprehensive user model and initialize all user data
      final userModel = await _userDataManager.setupNewUser(
        currentUser.uid,
        currentUser.email ?? '',
        currentUser.displayName ?? name.trim(),
      );
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
  
  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  /// Sign in as guest user
  Future<app_models.UserModel> loginAsGuest() async {
    try {
      final userCredential = await _firebaseAuth.signInAnonymously();
      
      if (userCredential.user == null) {
        throw Exception('Failed to sign in as guest');
      }
      
      return _userFromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Guest login failed: $e');
    }
  }

  // Convert Firebase User to our User model
  app_models.UserModel _userFromFirebaseUser(User user) {
    return app_models.UserModel(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? user.email?.split('@')[0] ?? 'User',
      photoUrl: user.photoURL,
    );
  }


  /// Handles Firebase Auth exceptions with simplified error messages
  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return Exception('Invalid email or password');
      case 'email-already-in-use':
        return Exception('Email already in use');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Invalid email address');
      default:
        return Exception(e.message ?? 'Authentication failed');
    }
  }
}
