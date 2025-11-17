import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dummy_e_commerce/models/address.dart';
import 'package:dummy_e_commerce/services/firestore_user_service.dart';

// Address States
abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;
  final Address? defaultAddress;

  AddressLoaded({
    required this.addresses,
    this.defaultAddress,
  });

  AddressLoaded copyWith({
    List<Address>? addresses,
    Address? defaultAddress,
  }) {
    return AddressLoaded(
      addresses: addresses ?? this.addresses,
      defaultAddress: defaultAddress ?? this.defaultAddress,
    );
  }
}

class AddressError extends AddressState {
  final String message;

  AddressError(this.message);
}

// Address Cubit
class AddressCubit extends Cubit<AddressState> {
  final FirestoreUserService _userService = FirestoreUserService();
  String? _currentUserId;

  AddressCubit() : super(AddressInitial());

  List<Address> _addresses = [];

  void setUserId(String userId) {
    print('AddressCubit: setUserId called with: $userId');
    _currentUserId = userId;
    loadUserAddresses();
  }

  void loadUserAddresses() async {
    if (_currentUserId == null) {
      print('AddressCubit: Cannot load addresses - no user ID set');
      return;
    }

    print('AddressCubit: Loading addresses for user: $_currentUserId');
    emit(AddressLoading());
    
    try {
      final addresses = await _userService.getUserAddresses(_currentUserId!);
      print('AddressCubit: Loaded ${addresses.length} addresses');
      
      _addresses = addresses;
      
      final defaultAddress = _addresses.where((address) => address.isDefault).firstOrNull;
      
      emit(AddressLoaded(
        addresses: _addresses,
        defaultAddress: defaultAddress,
      ));
    } catch (e) {
      print('AddressCubit: Error loading addresses: $e');
      emit(AddressError('Failed to load addresses: $e'));
    }
  }

  void addAddress(Address address) async {
    if (_currentUserId == null) {
      print('AddressCubit: Cannot add address - no user ID set');
      emit(AddressError('User not authenticated'));
      return;
    }

    if (state is! AddressLoaded) {
      print('AddressCubit: Cannot add address - invalid state');
      return;
    }

    try {
      print('AddressCubit: Adding address for user: $_currentUserId');
      
      final currentState = state as AddressLoaded;
      
      // If this is the first address or marked as default, make it default
      final isFirstAddress = _addresses.isEmpty;
      final shouldBeDefault = address.isDefault || isFirstAddress;
      
      final addressToAdd = address.copyWith(isDefault: shouldBeDefault);
      
      // Add to Firestore
      await _userService.addUserAddress(_currentUserId!, addressToAdd);
      print('AddressCubit: Address added successfully');
      
      // Reload addresses to get fresh data from Firestore
      loadUserAddresses();
      
    } catch (e) {
      print('AddressCubit: Error adding address: $e');
      emit(AddressError('Failed to add address: $e'));
    }
  }

  void updateAddress(Address updatedAddress) async {
    if (_currentUserId == null) {
      print('AddressCubit: Cannot update address - no user ID set');
      emit(AddressError('User not authenticated'));
      return;
    }

    if (state is! AddressLoaded) {
      print('AddressCubit: Cannot update address - invalid state');
      return;
    }

    try {
      print('AddressCubit: Updating address: ${updatedAddress.id}');
      
      // Update in Firestore
      await _userService.updateUserAddress(_currentUserId!, updatedAddress);
      print('AddressCubit: Address updated successfully');
      
      // Reload addresses to get fresh data from Firestore
      loadUserAddresses();
      
    } catch (e) {
      print('AddressCubit: Error updating address: $e');
      emit(AddressError('Failed to update address: $e'));
    }
  }

  void deleteAddress(String addressId) async {
    if (_currentUserId == null) {
      print('AddressCubit: Cannot delete address - no user ID set');
      emit(AddressError('User not authenticated'));
      return;
    }

    if (state is! AddressLoaded) {
      print('AddressCubit: Cannot delete address - invalid state');
      return;
    }

    try {
      print('AddressCubit: Deleting address: $addressId');
      
      // Delete from Firestore
      await _userService.removeUserAddress(_currentUserId!, addressId);
      print('AddressCubit: Address deleted successfully');
      
      // Reload addresses to get fresh data from Firestore
      loadUserAddresses();
      
    } catch (e) {
      print('AddressCubit: Error deleting address: $e');
      emit(AddressError('Failed to delete address: $e'));
    }
  }

  void setDefaultAddress(String addressId) async {
    if (_currentUserId == null) {
      print('AddressCubit: Cannot set default address - no user ID set');
      emit(AddressError('User not authenticated'));
      return;
    }

    if (state is! AddressLoaded) {
      print('AddressCubit: Cannot set default address - invalid state');
      return;
    }

    try {
      print('AddressCubit: Setting default address: $addressId');
      
      // Update in Firestore
      await _userService.setDefaultAddress(_currentUserId!, addressId);
      print('AddressCubit: Default address set successfully');
      
      // Reload addresses to get fresh data from Firestore
      loadUserAddresses();
      
    } catch (e) {
      print('AddressCubit: Error setting default address: $e');
      emit(AddressError('Failed to set default address: $e'));
    }
  }

  Address? getAddressById(String id) {
    try {
      return _addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }

  void refreshAddresses() {
    loadUserAddresses();
  }

  void clear() {
    print('AddressCubit: Clearing addresses');
    _currentUserId = null;
    _addresses = [];
    emit(AddressInitial());
  }
}
