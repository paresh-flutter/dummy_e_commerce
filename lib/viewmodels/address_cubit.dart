import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dummy_e_commerce/models/address.dart';

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
  AddressCubit() : super(AddressInitial()) {
    _loadAddresses();
  }

  List<Address> _addresses = [];

  void _loadAddresses() {
    emit(AddressLoading());
    
    // Simulate loading from storage/API
    // In a real app, this would load from SharedPreferences, SQLite, or API
    _addresses = [
      Address(
        id: '1',
        fullName: 'John Doe',
        phoneNumber: '+1 234 567 8900',
        addressLine1: '123 Main Street',
        addressLine2: 'Apt 4B',
        city: 'New York',
        state: 'NY',
        zipCode: '10001',
        country: 'United States',
        isDefault: true,
        label: 'Home',
      ),
      Address(
        id: '2',
        fullName: 'John Doe',
        phoneNumber: '+1 234 567 8900',
        addressLine1: '456 Business Ave',
        city: 'New York',
        state: 'NY',
        zipCode: '10002',
        country: 'United States',
        isDefault: false,
        label: 'Work',
      ),
    ];

    final defaultAddress = _addresses.firstWhere(
      (address) => address.isDefault,
      orElse: () => _addresses.isNotEmpty ? _addresses.first : Address(
        id: '',
        fullName: '',
        phoneNumber: '',
        addressLine1: '',
        city: '',
        state: '',
        zipCode: '',
        country: '',
      ),
    );

    emit(AddressLoaded(
      addresses: _addresses,
      defaultAddress: defaultAddress.id.isNotEmpty ? defaultAddress : null,
    ));
  }

  void addAddress(Address address) {
    if (state is AddressLoaded) {
      final currentState = state as AddressLoaded;
      
      // If this is the first address or marked as default, make it default
      final isFirstAddress = _addresses.isEmpty;
      final shouldBeDefault = address.isDefault || isFirstAddress;
      
      // If making this default, remove default from others
      if (shouldBeDefault) {
        _addresses = _addresses.map((addr) => addr.copyWith(isDefault: false)).toList();
      }
      
      final newAddress = address.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isDefault: shouldBeDefault,
      );
      
      _addresses.add(newAddress);
      
      final defaultAddress = shouldBeDefault ? newAddress : currentState.defaultAddress;
      
      emit(AddressLoaded(
        addresses: List.from(_addresses),
        defaultAddress: defaultAddress,
      ));
      
      _saveAddresses();
    }
  }

  void updateAddress(Address updatedAddress) {
    if (state is AddressLoaded) {
      final currentState = state as AddressLoaded;
      
      // If making this default, remove default from others
      if (updatedAddress.isDefault) {
        _addresses = _addresses.map((addr) => 
          addr.id == updatedAddress.id ? addr : addr.copyWith(isDefault: false)
        ).toList();
      }
      
      final index = _addresses.indexWhere((addr) => addr.id == updatedAddress.id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
        
        final defaultAddress = updatedAddress.isDefault ? updatedAddress : 
          (currentState.defaultAddress?.id == updatedAddress.id ? null : currentState.defaultAddress);
        
        emit(AddressLoaded(
          addresses: List.from(_addresses),
          defaultAddress: defaultAddress ?? _addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => _addresses.isNotEmpty ? _addresses.first : Address(
              id: '',
              fullName: '',
              phoneNumber: '',
              addressLine1: '',
              city: '',
              state: '',
              zipCode: '',
              country: '',
            ),
          ),
        ));
        
        _saveAddresses();
      }
    }
  }

  void deleteAddress(String addressId) {
    if (state is AddressLoaded) {
      final currentState = state as AddressLoaded;
      final addressToDelete = _addresses.firstWhere((addr) => addr.id == addressId);
      
      _addresses.removeWhere((addr) => addr.id == addressId);
      
      Address? newDefaultAddress = currentState.defaultAddress;
      
      // If we deleted the default address, make the first remaining address default
      if (addressToDelete.isDefault && _addresses.isNotEmpty) {
        _addresses[0] = _addresses[0].copyWith(isDefault: true);
        newDefaultAddress = _addresses[0];
      } else if (addressToDelete.isDefault) {
        newDefaultAddress = null;
      }
      
      emit(AddressLoaded(
        addresses: List.from(_addresses),
        defaultAddress: newDefaultAddress,
      ));
      
      _saveAddresses();
    }
  }

  void setDefaultAddress(String addressId) {
    if (state is AddressLoaded) {
      // Remove default from all addresses
      _addresses = _addresses.map((addr) => addr.copyWith(isDefault: false)).toList();
      
      // Set the selected address as default
      final index = _addresses.indexWhere((addr) => addr.id == addressId);
      if (index != -1) {
        _addresses[index] = _addresses[index].copyWith(isDefault: true);
        
        emit(AddressLoaded(
          addresses: List.from(_addresses),
          defaultAddress: _addresses[index],
        ));
        
        _saveAddresses();
      }
    }
  }

  Address? getAddressById(String id) {
    try {
      return _addresses.firstWhere((addr) => addr.id == id);
    } catch (e) {
      return null;
    }
  }

  void _saveAddresses() {
    // In a real app, save to SharedPreferences, SQLite, or API
    // For now, we'll just keep them in memory
  }

  void refreshAddresses() {
    _loadAddresses();
  }
}
