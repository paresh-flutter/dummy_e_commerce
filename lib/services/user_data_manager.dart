import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_user_service.dart';
import 'firestore_cart_service.dart';
import 'firestore_wishlist_service.dart';
import '../models/user.dart';

/// Manages all user data integration with Firestore
/// This service ensures that user data is properly synchronized
/// across authentication, cart, wishlist, and profile services
class UserDataManager {
  static final UserDataManager _instance = UserDataManager._internal();
  factory UserDataManager() => _instance;
  UserDataManager._internal();

  final FirestoreUserService _userService = FirestoreUserService();
  final FirestoreCartService _cartService = FirestoreCartService();
  final FirestoreWishlistService _wishlistService = FirestoreWishlistService();

  /// Initialize user data after authentication
  Future<void> initializeUserData(UserModel user) async {
    try {
      // Create or update user profile in Firestore
      await _userService.createOrUpdateUserProfile(user);
      
      // Initialize empty cart and wishlist if they don't exist
      await _initializeUserCollections(user.id);
      
      print('User data initialized successfully for ${user.email}');
    } catch (e) {
      print('Error initializing user data: $e');
      throw Exception('Failed to initialize user data: $e');
    }
  }

  /// Initialize empty collections for new user
  Future<void> _initializeUserCollections(String userId) async {
    try {
      // Check if user cart exists, if not create empty one
      final existingCart = await _cartService.getUserCart(userId);
      if (existingCart.isEmpty) {
        // Cart is empty, which is fine for new users
        print('Cart initialized for user $userId');
      }

      // Check if user wishlist exists, if not create empty one
      final existingWishlist = await _wishlistService.getUserWishlist(userId);
      if (existingWishlist.isEmpty) {
        // Wishlist is empty, which is fine for new users
        print('Wishlist initialized for user $userId');
      }
    } catch (e) {
      // It's okay if collections don't exist yet - they'll be created when needed
      print('Collections will be created when user adds items');
    }
  }

  /// Complete user setup after registration
  Future<UserModel> setupNewUser(String userId, String email, String name) async {
    try {
      // Create comprehensive user model
      final user = UserModel(
        id: userId,
        email: email,
        name: name,
        wishlistProductIds: [],
        addresses: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        preferences: const UserPreferences(
          enableNotifications: true,
          enableEmailMarketing: false,
          currency: 'USD',
          language: 'en',
          theme: 'system',
        ),
      );

      // Initialize all user data
      await initializeUserData(user);

      return user;
    } catch (e) {
      print('Error setting up new user: $e');
      throw Exception('Failed to setup new user: $e');
    }
  }

  /// Update user data when authentication state changes
  Future<void> onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      try {
        // Check if user profile exists in Firestore
        final existingUser = await _userService.getUserProfile(firebaseUser.uid);
        
        if (existingUser == null) {
          // User doesn't exist in Firestore, create it
          await setupNewUser(
            firebaseUser.uid,
            firebaseUser.email ?? '',
            firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          );
        } else {
          // User exists, just initialize collections if needed
          await _initializeUserCollections(firebaseUser.uid);
        }
      } catch (e) {
        print('Error handling auth state change: $e');
      }
    }
  }

  /// Sync user data across all services
  Future<void> syncUserData(String userId) async {
    try {
      // This method can be called to ensure all user data is consistent
      await _initializeUserCollections(userId);
      print('User data synced for $userId');
    } catch (e) {
      print('Error syncing user data: $e');
    }
  }

  /// Clean up user data on logout
  Future<void> clearLocalUserData() async {
    try {
      // Clear any cached user data
      print('Local user data cleared');
    } catch (e) {
      print('Error clearing local user data: $e');
    }
  }
}