import 'package:dummy_e_commerce/models/address.dart';
import 'package:dummy_e_commerce/viewmodels/address_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddEditAddressScreen extends StatefulWidget {
  final Address? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  String _selectedLabel = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _populateFields(widget.address!);
    } else {
      //_countryController.text = 'United States';
    }
  }

  void _populateFields(Address address) {
    _fullNameController.text = address.fullName;
    _phoneController.text = address.phoneNumber;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2;
    _cityController.text = address.city;
    _stateController.text = address.state;
    _zipCodeController.text = address.zipCode;
    _countryController.text = address.country;
    _selectedLabel = address.label;
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.address == null ? 'Add Address' : 'Edit Address',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Label Selection
                      Text(
                        'Address Label',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: ['Home', 'Work', 'Other'].map((label) {
                          final isSelected = _selectedLabel == label;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedLabel = label),
                              child: Container(
                                margin: EdgeInsets.only(right: label != 'Other' ? 8.w : 0),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? colorScheme.primary : colorScheme.outline,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
        
                      SizedBox(height: 24.h),
        
                      // Contact Information
                      Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
        
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person_outline, size: 20.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter full name';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
        
                      SizedBox(height: 16.h),
        
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter phone number';
                          }
                          if (value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
        
                      SizedBox(height: 24.h),
        
                      // Address Information
                      Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.h),
        
                      TextFormField(
                        controller: _addressLine1Controller,
                        decoration: InputDecoration(
                          labelText: 'Address Line 1 *',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter address';
                          }
                          return null;
                        },
                      ),
        
                      SizedBox(height: 16.h),
        
                      TextFormField(
                        controller: _addressLine2Controller,
                        decoration: InputDecoration(
                          labelText: 'Address Line 2 (Optional)',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
        
                      SizedBox(height: 16.h),
        
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: 'City *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter city';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _stateController,
                              decoration: InputDecoration(
                                labelText: 'State *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter state';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 16.h),
        
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _zipCodeController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'ZIP Code *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter ZIP';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _countryController,
                              decoration: InputDecoration(
                                labelText: 'Country *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter country';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 24.h),
        
                      // Default Address Toggle
                      Row(
                        children: [
                          Checkbox(
                            value: _isDefault,
                            onChanged: (value) => setState(() => _isDefault = value ?? false),
                          ),
                          Text(
                            'Set as default address',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ],
                      ),
        
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: theme.colorScheme.surface,
              padding: EdgeInsets.all(20.w),

              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.address == null ? 'Add Address' : 'Update Address',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        id: widget.address?.id ?? '',
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        country: _countryController.text.trim(),
        isDefault: _isDefault,
        label: _selectedLabel,
      );

      if (widget.address == null) {
        context.read<AddressCubit>().addAddress(address);
      } else {
        context.read<AddressCubit>().updateAddress(address);
      }

      context.pop();
    }
  }
}