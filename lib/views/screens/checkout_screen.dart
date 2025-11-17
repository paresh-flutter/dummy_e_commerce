import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import '../../utils/price_formatter.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../viewmodels/auth_cubit.dart';
import '../../viewmodels/order_cubit.dart';
import '../../viewmodels/address_cubit.dart';
import '../../models/address.dart';
import '../../models/order.dart';
import '../../widgets/cart_icon_button.dart';
import '../../services/stripe_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _shippingFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();
  
  // Shipping Address Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  
  // Payment Controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  
  String _selectedPaymentMethod = 'credit_card';
  Address? _selectedAddress;
  bool _useNewAddress = false;
  
  final List<String> _stepTitles = [
    'Shipping Address',
    'Payment Method',
    'Order Review',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose shipping controllers
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    // Dispose payment controllers
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Shipping Address
        return _shippingFormKey.currentState?.validate() ?? false;
      case 1: // Payment Method
        return _paymentFormKey.currentState?.validate() ?? false;
      case 2: // Order Review
        return true;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep() && _currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? colorScheme.tertiary
                            : isActive
                                ? colorScheme.primary
                                : colorScheme.outline,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: colorScheme.onTertiary,
                                size: 18.sp,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                      ),
                    ),
                    // Progress line (except for last step)
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 2.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          color: isCompleted
                              ? colorScheme.tertiary
                              : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          SizedBox(height: 12.h),
          
          // Step titles
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isActive = index == _currentStep;
              
              return Expanded(
                child: Text(
                  _stepTitles[index],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    final orderCubit = context.read<OrderCubit>();
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: const [CartIconButton()],
      ),
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<OrderCubit, OrderState>(
              listener: (context, state) {
                if (state is OrderCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order ${state.order.id} placed successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  );
                  cart.clear();
                  context.go('/home');
                } else if (state is OrderError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final items = cartState.items.values.toList();
              
              if (items.isEmpty) {
                return const Center(child: Text('No items to checkout'));
              }
              
              return Column(
                children: [
                  // Progress Indicator
                  _buildProgressIndicator(),
                  
                  // Step Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      children: [
                        _buildShippingStep(),
                        _buildPaymentStep(),
                        _buildReviewStep(cart, items),
                      ],
                    ),
                  ),
                  
                  // Navigation Buttons
                  _buildNavigationButtons(cart, orderCubit, authCubit),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShippingStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping Address',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _shippingFormKey,
                child: Column(
                  children: [
                    // Contact Information Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Contact Information',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // Full Name Field
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person, size: 20.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          
                          SizedBox(height: 16.h),
                          
                          // Phone Number Field
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number *',
                              hintText: 'Enter your phone number',
                              prefixIcon: Icon(Icons.phone, size: 20.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 16.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.trim().length < 10) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Address Selection Section
                    BlocBuilder<AddressCubit, AddressState>(
                      builder: (context, addressState) {
                        if (addressState is AddressLoaded && addressState.addresses.isNotEmpty) {
                          return Column(
                            children: [
                              // Saved Addresses Section
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(20.w),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                                      blurRadius: 8.r,
                                      offset: Offset(0, 2.h),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 20.sp,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Select Delivery Address',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.h),
                                    
                                    // Address List
                                    ...addressState.addresses.map((address) => 
                                      _buildAddressOption(address, Theme.of(context).colorScheme)
                                    ).toList(),
                                    
                                    SizedBox(height: 16.h),
                                    
                                    // Use New Address Option
                                    GestureDetector(
                                      onTap: () => setState(() {
                                        _useNewAddress = true;
                                        _selectedAddress = null;
                                      }),
                                      child: Container(
                                        padding: EdgeInsets.all(16.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: _useNewAddress 
                                              ? Theme.of(context).colorScheme.primary 
                                              : Theme.of(context).colorScheme.outline,
                                            width: _useNewAddress ? 2 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _useNewAddress ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                              color: _useNewAddress 
                                                ? Theme.of(context).colorScheme.primary 
                                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 12.w),
                                            Icon(Icons.add_location_outlined, size: 20.sp),
                                            SizedBox(width: 8.w),
                                            Text(
                                              'Use a new address',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Show manual form if "Use new address" is selected
                              if (_useNewAddress) ...[
                                SizedBox(height: 16.h),
                                _buildManualAddressForm(),
                              ],
                            ],
                          );
                        } else {
                          // No saved addresses, show manual form
                          return _buildManualAddressForm();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _paymentFormKey,
                child: Column(
                  children: [
                    // Payment Method Selection
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 20.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Select Payment Method',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // Credit Card Option
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPaymentMethod == 'credit_card'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: _selectedPaymentMethod == 'credit_card' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: RadioListTile<String>(
                              value: 'credit_card',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              title: Row(
                                children: [
                                  Icon(Icons.credit_card, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Credit/Debit Card',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Visa, Mastercard, American Express',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          // PayPal Option
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPaymentMethod == 'paypal'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: _selectedPaymentMethod == 'paypal' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: RadioListTile<String>(
                              value: 'paypal',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              title: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'PayPal',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Pay with your PayPal account',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          // Apple Pay Option
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPaymentMethod == 'apple_pay'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.outline,
                                width: _selectedPaymentMethod == 'apple_pay' ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: RadioListTile<String>(
                              value: 'apple_pay',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              title: Row(
                                children: [
                                  Icon(Icons.phone_iphone, size: 20.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Apple Pay',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'Pay with Touch ID or Face ID',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Credit Card Form (only show when credit card is selected)
                    if (_selectedPaymentMethod == 'credit_card')...[
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 8.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card,
                                  size: 20.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Card Information',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            
                            // Card Number
                            TextFormField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Card Number *',
                                hintText: '1234 5678 9012 3456',
                                prefixIcon: Icon(Icons.credit_card, size: 20.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                              ),
                              validator: (value) {
                                if (_selectedPaymentMethod == 'credit_card') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter card number';
                                  }
                                  if (value.replaceAll(' ', '').length < 16) {
                                    return 'Please enter a valid card number';
                                  }
                                }
                                return null;
                              },
                              onChanged: (value) {
                                // Format card number with spaces
                                String formatted = value.replaceAll(' ', '');
                                if (formatted.length > 16) {
                                  formatted = formatted.substring(0, 16);
                                }
                                String display = '';
                                for (int i = 0; i < formatted.length; i++) {
                                  if (i > 0 && i % 4 == 0) {
                                    display += ' ';
                                  }
                                  display += formatted[i];
                                }
                                if (display != value) {
                                  _cardNumberController.value = TextEditingValue(
                                    text: display,
                                    selection: TextSelection.collapsed(offset: display.length),
                                  );
                                }
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Card Holder Name
                            TextFormField(
                              controller: _cardHolderController,
                              decoration: InputDecoration(
                                labelText: 'Cardholder Name *',
                                hintText: 'John Doe',
                                prefixIcon: Icon(Icons.person, size: 20.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                              ),
                              validator: (value) {
                                if (_selectedPaymentMethod == 'credit_card') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter cardholder name';
                                  }
                                }
                                return null;
                              },
                            ),
                            
                            SizedBox(height: 16.h),
                            
                            // Expiry and CVV Row
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _expiryController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Expiry Date *',
                                      hintText: 'MM/YY',
                                      prefixIcon: Icon(Icons.date_range, size: 20.sp),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_selectedPaymentMethod == 'credit_card') {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Enter expiry';
                                        }
                                        if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
                                          return 'Invalid format';
                                        }
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      // Format MM/YY
                                      String formatted = value.replaceAll('/', '');
                                      if (formatted.length > 4) {
                                        formatted = formatted.substring(0, 4);
                                      }
                                      if (formatted.length >= 2) {
                                        formatted = '${formatted.substring(0, 2)}/${formatted.substring(2)}';
                                      }
                                      if (formatted != value) {
                                        _expiryController.value = TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(offset: formatted.length),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: TextFormField(
                                    controller: _cvvController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'CVV *',
                                      hintText: '123',
                                      prefixIcon: Icon(Icons.lock, size: 20.sp),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (_selectedPaymentMethod == 'credit_card') {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Enter CVV';
                                        }
                                        if (value.length < 3) {
                                          return 'Invalid CVV';
                                        }
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      if (value.length > 4) {
                                        _cvvController.value = TextEditingValue(
                                          text: value.substring(0, 4),
                                          selection: TextSelection.collapsed(offset: 4),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep(CartCubit cart, List items) {
    final total = cart.total;
    final itemCount = cart.itemCount;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Review',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Shipping Address Section
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 20.sp,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Shipping Address',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _fullNameController.text.isNotEmpty ? _fullNameController.text : 'Not provided',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_phoneController.text.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              _phoneController.text,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                          SizedBox(height: 8.h),
                          Text(
                            _buildAddressString(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Payment Method Section
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.payment_outlined,
                                size: 20.sp,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Payment Method',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Icon(
                                _getPaymentIcon(),
                                size: 24.sp,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getPaymentMethodName(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_selectedPaymentMethod == 'credit_card' && _cardNumberController.text.isNotEmpty) ...[
                                    SizedBox(height: 2.h),
                                    Text(
                                      '**** **** **** ${_cardNumberController.text.replaceAll(' ', '').substring(_cardNumberController.text.replaceAll(' ', '').length - 4)}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Order Items
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 20.sp,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Order Items ($itemCount items)',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...items.map((item) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6.r),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: 40.w,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 40.w,
                                      height: 40.h,
                                      color: Theme.of(context).colorScheme.surfaceContainer,
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                        size: 16.sp,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Qty: ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                PriceFormatter.format(item.totalPrice),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Order Summary
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.05),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.receipt_outlined,
                              size: 20.sp,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              PriceFormatter.format(total),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              'FREE',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tax',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                            Text(
                              PriceFormatter.format(total * 0.1),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Divider(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              PriceFormatter.format(total + (total * 0.1)),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(CartCubit cart, OrderCubit orderCubit, AuthCubit authCubit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) SizedBox(width: 16.w),
          
          // Next/Place Order Button
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                final isLoading = orderState is OrderLoading;
                final isLastStep = _currentStep == _stepTitles.length - 1;
                
                return ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (isLastStep) {
                      // Place Order
                      if (cart.itemCount == 0) return;

                      final authState = authCubit.state;
                      if (authState is AuthAuthenticated) {
                        try {
                          // Variables to hold Stripe payment response
                          Map<String, dynamic>? stripePaymentResult;
                          String? stripePaymentIntentId;
                          String? stripePaymentStatus;

                          // Process Stripe payment if credit card is selected
                          if (_selectedPaymentMethod == 'credit_card') {
                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16.h),
                                        Text('Processing payment...'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            try {
                              // Calculate total with tax
                              final total = cart.total + (cart.total * 0.1);
                              
                              // Process Stripe payment
                              stripePaymentResult = await StripeService.instance.makePayment(total);
                              
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              if (stripePaymentResult == null) {
                                throw Exception('Payment was not completed');
                              }

                              // Extract payment details from Stripe response
                              stripePaymentIntentId = stripePaymentResult['id'] as String?;
                              stripePaymentStatus = stripePaymentResult['status'] as String?;
                              
                              debugPrint('Stripe payment successful: ID=$stripePaymentIntentId, Status=$stripePaymentStatus');
                            } catch (e) {
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // Show error message
                              if (context.mounted) {
                                debugPrint('PAYMENT ERROR: ${e.toString()}');
                                String errorMessage = 'Payment failed';

                                if (e.toString().contains('No host specified') ||
                                    e.toString().contains('YOUR_BACKEND_URL')) {
                                  errorMessage = 'Stripe backend not configured. Please set up your backend server first.';
                                } else {
                                  errorMessage = 'Payment failed: ${e.toString()}';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage, maxLines: 3),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                              return;
                            }
                          } else if (_selectedPaymentMethod == 'apple_pay') {
                            // Show loading dialog
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16.h),
                                        Text('Processing payment...'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );

                            try {
                              // Calculate total with tax
                              final total = cart.total + (cart.total * 0.1);
                              
                              // Process Stripe payment
                              stripePaymentResult = await StripeService.instance.payWithApplePay(total);
                              
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              if (stripePaymentResult == null) {
                                throw Exception('Payment was not completed');
                              }

                              // Extract payment details from Stripe response
                              stripePaymentIntentId = stripePaymentResult['id'] as String?;
                              stripePaymentStatus = stripePaymentResult['status'] as String?;
                              
                              debugPrint('APPLE payment successful: ID=$stripePaymentIntentId, Status=$stripePaymentStatus');
                            } catch (e) {
                              // Close loading dialog
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }

                              // Show error message
                              if (context.mounted) {
                                debugPrint('APPLE PAY ERROR: ${e.toString()}');
                                String errorMessage = 'Apple Pay failed';

                                if (e.toString().contains('canceled by user')) {
                                  errorMessage = 'Apple Pay was canceled';
                                } else if (e.toString().contains('not supported')) {
                                  errorMessage = 'Apple Pay is not available on this device';
                                } else if (e.toString().contains('No host specified') ||
                                    e.toString().contains('YOUR_BACKEND_URL')) {
                                  errorMessage = 'Payment backend not configured. Please set up your backend server first.';
                                } else if (e.toString().contains('Failed to create payment intent')) {
                                  errorMessage = 'Unable to process payment. Please check your internet connection.';
                                } else {
                                  errorMessage = 'Apple Pay failed: ${e.toString().replaceAll('Exception: ', '')}';
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage, maxLines: 3),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                              return;
                            }
                          }

                          // Create shipping address from form data
                          final shippingAddress = _selectedAddress ?? Address(
                            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                            fullName: _fullNameController.text.trim(),
                            phoneNumber: _phoneController.text.trim(),
                            addressLine1: _addressLine1Controller.text.trim(),
                            addressLine2: _addressLine2Controller.text.trim(),
                            city: _cityController.text.trim(),
                            state: _stateController.text.trim(),
                            zipCode: _zipCodeController.text.trim(),
                            country: _countryController.text.trim().isEmpty ? 'United States' : _countryController.text.trim(),
                            label: 'Shipping',
                            isDefault: false,
                          );

                          // Create payment details with Stripe information
                          final paymentDetails = PaymentDetails(
                            method: _getPaymentMethod(_selectedPaymentMethod),
                            cardLastFour: _cardNumberController.text.trim().isNotEmpty
                              ? _cardNumberController.text.trim().replaceAll(' ', '').substring(_cardNumberController.text.trim().replaceAll(' ', '').length - 4)
                              : null,
                            cardBrand: _getCardBrand(_cardNumberController.text.trim()),
                            amount: cart.total + (cart.total * 0.1), // Total with tax
                            transactionDate: DateTime.now(),
                            stripePaymentIntentId: stripePaymentIntentId,
                            stripePaymentStatus: stripePaymentStatus,
                          );

                          // Create order in Firestore with payment details
                          await orderCubit.createOrder(
                            cartItems: cart.state.items,
                            userId: authState.user.id,
                            shippingAddress: shippingAddress,
                            paymentDetails: paymentDetails,
                          );

                          // Log successful payment storage
                          debugPrint('Order created with payment details - Method: ${paymentDetails.method}, Amount: ${paymentDetails.amount}');
                          if (stripePaymentIntentId != null) {
                            debugPrint('Stripe Payment Intent ID: $stripePaymentIntentId stored with order');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            debugPrint('PAYMENT ERROR : ${e.toString()}');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Please log in to place an order'),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    } else {
                      // Next Step
                      _nextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.surface),
                          ),
                        )
                      : Text(
                          isLastStep ? 'Place Order' : 'Continue',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _buildAddressString() {
    List<String> addressParts = [];
    
    if (_addressLine1Controller.text.isNotEmpty) {
      addressParts.add(_addressLine1Controller.text);
    }
    if (_addressLine2Controller.text.isNotEmpty) {
      addressParts.add(_addressLine2Controller.text);
    }
    if (_cityController.text.isNotEmpty) {
      addressParts.add(_cityController.text);
    }
    if (_stateController.text.isNotEmpty) {
      addressParts.add(_stateController.text);
    }
    if (_zipCodeController.text.isNotEmpty) {
      addressParts.add(_zipCodeController.text);
    }
    if (_countryController.text.isNotEmpty) {
      addressParts.add(_countryController.text);
    }
    
    return addressParts.isNotEmpty ? addressParts.join(', ') : 'Address not provided';
  }

  IconData _getPaymentIcon() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet;
      case 'apple_pay':
        return Icons.phone_iphone;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodName() {
    switch (_selectedPaymentMethod) {
      case 'credit_card':
        return 'Credit/Debit Card';
      case 'paypal':
        return 'PayPal';
      case 'apple_pay':
        return 'Apple Pay';
      default:
        return 'Not selected';
    }
  }

  Widget _buildAddressOption(Address address, ColorScheme colorScheme) {
    final isSelected = _selectedAddress?.id == address.id;
    
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAddress = address;
        _useNewAddress = false;
        // Populate form fields with selected address
        _fullNameController.text = address.fullName;
        _phoneController.text = address.phoneNumber;
        _addressLine1Controller.text = address.addressLine1;
        _addressLine2Controller.text = address.addressLine2;
        _cityController.text = address.city;
        _stateController.text = address.state;
        _zipCodeController.text = address.zipCode;
        _countryController.text = address.country;
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? colorScheme.primary : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.05) : Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getLabelColor(address.label).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          address.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: _getLabelColor(address.label),
                          ),
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    address.fullName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.shortAddress,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Colors.blue;
      case 'work':
        return Colors.orange;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildManualAddressForm() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Address Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Address Line 1
          TextFormField(
            controller: _addressLine1Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 1 *',
              hintText: 'Street address, P.O. box, company name',
              prefixIcon: Icon(Icons.home, size: 20.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
            validator: (value) {
              if (_useNewAddress || _selectedAddress == null) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your address';
                }
              }
              return null;
            },
          ),
          
          SizedBox(height: 16.h),
          
          // Address Line 2
          TextFormField(
            controller: _addressLine2Controller,
            decoration: InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              hintText: 'Apartment, suite, unit, building, floor',
              prefixIcon: Icon(Icons.business, size: 20.sp),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // City and State Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: 'City *',
                    hintText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (_useNewAddress || _selectedAddress == null) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter city';
                      }
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
                    hintText: 'State',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (_useNewAddress || _selectedAddress == null) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter state';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // ZIP Code and Country Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _zipCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ZIP Code *',
                    hintText: 'ZIP',
                    prefixIcon: Icon(Icons.markunread_mailbox, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (_useNewAddress || _selectedAddress == null) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter ZIP';
                      }
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _countryController,
                  decoration: InputDecoration(
                    labelText: 'Country *',
                    hintText: 'Enter country',
                    prefixIcon: Icon(Icons.public, size: 20.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                  validator: (value) {
                    if (_useNewAddress || _selectedAddress == null) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter country';
                      }
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper methods for payment processing
PaymentMethod _getPaymentMethod(String method) {
  switch (method.toLowerCase()) {
    case 'credit_card':
      return PaymentMethod.creditCard;
    case 'paypal':
      return PaymentMethod.paypal;
    case 'apple_pay':
      return PaymentMethod.applePay;
    default:
      return PaymentMethod.creditCard;
  }
}

  String? _getCardBrand(String cardNumber) {
    if (cardNumber.isEmpty) return null;
    
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.startsWith('4')) return 'Visa';
    if (cleaned.startsWith('5')) return 'Mastercard';
    if (cleaned.startsWith('3')) return 'American Express';
    return 'Unknown';
  }
