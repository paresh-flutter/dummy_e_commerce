import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/address.dart';

/// Comprehensive service to manage user data and addresses in Firestore
class FirestoreUserService {
  static final FirestoreUserService _instance = FirestoreUserService._internal();
  factory FirestoreUserService() => _instance;
  FirestoreUserService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create or update user profile in Firestore
  Future<void> createOrUpdateUserProfile(UserModel user) async {
    try {
      final userData = user.toMap();
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _usersCollection.doc(user.id).set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to create/update user profile: $e');
    }
  }

  /// Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserModel user) async {
    try {
      final updateData = user.toMap();
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _usersCollection.doc(user.id).update(updateData);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      fields['updatedAt'] = FieldValue.serverTimestamp();
      await _usersCollection.doc(userId).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  /// Add address to user profile
  Future<void> addUserAddress(String userId, Address address) async {
    try {
      // If this is the first address, make it default
      final user = await getUserProfile(userId);
      bool shouldSetDefault = user?.addresses.isEmpty ?? true;
      
      if (shouldSetDefault || address.isDefault) {
        // Remove default from other addresses
        await _removeDefaultFromAllAddresses(userId);
      }

      final addressData = address.copyWith(isDefault: shouldSetDefault || address.isDefault).toMap();
      
      await _usersCollection.doc(userId).update({
        'addresses': FieldValue.arrayUnion([addressData]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add user address: $e');
    }
  }

  /// Update user address
  Future<void> updateUserAddress(String userId, Address updatedAddress) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final addresses = List<Address>.from(user.addresses);
      final index = addresses.indexWhere((addr) => addr.id == updatedAddress.id);
      
      if (index == -1) {
        throw Exception('Address not found');
      }

      // If setting this address as default, remove default from others
      if (updatedAddress.isDefault) {
        addresses.forEach((addr) {
          if (addr.id != updatedAddress.id) {
            addresses[addresses.indexOf(addr)] = addr.copyWith(isDefault: false);
          }
        });
      }

      addresses[index] = updatedAddress;

      await _usersCollection.doc(userId).update({
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  /// Remove user address
  Future<void> removeUserAddress(String userId, String addressId) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final addresses = user.addresses.where((addr) => addr.id != addressId).toList();
      
      // If we removed the default address, make the first remaining address default
      if (addresses.isNotEmpty && !addresses.any((addr) => addr.isDefault)) {
        addresses[0] = addresses[0].copyWith(isDefault: true);
      }

      await _usersCollection.doc(userId).update({
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove user address: $e');
    }
  }

  /// Set default address for user
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final addresses = user.addresses.map((addr) {
        return addr.copyWith(isDefault: addr.id == addressId);
      }).toList();

      await _usersCollection.doc(userId).update({
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }

  /// Get user addresses
  Future<List<Address>> getUserAddresses(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.addresses ?? [];
    } catch (e) {
      throw Exception('Failed to get user addresses: $e');
    }
  }

  /// Get user's default address
  Future<Address?> getUserDefaultAddress(String userId) async {
    try {
      final user = await getUserProfile(userId);
      return user?.primaryAddress;
    } catch (e) {
      throw Exception('Failed to get user default address: $e');
    }
  }

  /// Update user preferences
  Future<void> updateUserPreferences(String userId, UserPreferences preferences) async {
    try {
      await _usersCollection.doc(userId).update({
        'preferences': preferences.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user preferences: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final allUsersSnapshot = await _usersCollection.get();
      final adminUsersSnapshot = await _usersCollection
          .where('isAdmin', isEqualTo: true)
          .get();

      final totalUsers = allUsersSnapshot.docs.length;
      final adminUsers = adminUsersSnapshot.docs.length;
      final regularUsers = totalUsers - adminUsers;

      // Calculate recent registrations (last 30 days)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentUsers = allUsersSnapshot.docs.where((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        return createdAt != null && createdAt.toDate().isAfter(thirtyDaysAgo);
      }).length;

      return {
        'totalUsers': totalUsers,
        'adminUsers': adminUsers,
        'regularUsers': regularUsers,
        'recentRegistrations': recentUsers,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get user statistics: $e');
    }
  }

  /// Stream user profile for real-time updates
  Stream<UserModel?> getUserProfileStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Delete user profile (admin functionality)
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  /// Helper method to remove default flag from all addresses
  Future<void> _removeDefaultFromAllAddresses(String userId) async {
    try {
      final user = await getUserProfile(userId);
      if (user == null) return;

      final addresses = user.addresses.map((addr) => 
          addr.copyWith(isDefault: false)
      ).toList();

      await _usersCollection.doc(userId).update({
        'addresses': addresses.map((addr) => addr.toMap()).toList(),
      });
    } catch (e) {
      // Ignore errors in this helper method
    }
  }

  /// Bulk update user data (admin functionality)
  Future<void> bulkUpdateUsers(List<String> userIds, Map<String, dynamic> updates) async {
    try {
      final batch = _firestore.batch();
      updates['updatedAt'] = FieldValue.serverTimestamp();

      for (final userId in userIds) {
        batch.update(_usersCollection.doc(userId), updates);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to bulk update users: $e');
    }
  }
}