import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/theme_cubit.dart';
import '../../viewmodels/auth_cubit.dart';
import '../../services/authentication_service.dart';
import '../../services/firestore_user_service.dart';
import '../../services/firestore_cart_service.dart';
import '../../services/firestore_wishlist_service.dart';
import '../../services/user_data_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricAuth = false;
  bool _autoBackup = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'USD';
  bool _isDeleting = false;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Italian'];
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];
  
  // Services
  final AuthenticationService _authService = AuthenticationService();
  final FirestoreUserService _userService = FirestoreUserService();
  final FirestoreCartService _cartService = FirestoreCartService();
  final FirestoreWishlistService _wishlistService = FirestoreWishlistService();
  final UserDataManager _userDataManager = UserDataManager();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Appearance
              _buildSection(
                'Appearance',
                [
                  BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return _buildThemeSelector(context, themeState);
                    },
                  ),
                  _buildDropdownTile(
                    'Language',
                    'Choose your preferred language',
                    Icons.language_outlined,
                    _selectedLanguage,
                    _languages,
                    (value) => setState(() => _selectedLanguage = value!),
                  ),
                  _buildDropdownTile(
                    'Currency',
                    'Select your preferred currency',
                    Icons.attach_money_outlined,
                    _selectedCurrency,
                    _currencies,
                    (value) => setState(() => _selectedCurrency = value!),
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Security
              _buildSection(
                'Security',
                [
                  _buildSwitchTile(
                    'Biometric Authentication',
                    'Use fingerprint or face ID to unlock',
                    Icons.fingerprint_outlined,
                    _biometricAuth,
                    (value) => setState(() => _biometricAuth = value),
                  ),
                  _buildActionTile(
                    'Change Password',
                    'Update your account password',
                    Icons.lock_outline,
                    () => _showChangePasswordDialog(),
                  ),
                  _buildActionTile(
                    'Two-Factor Authentication',
                    'Add an extra layer of security',
                    Icons.security_outlined,
                    () => _showComingSoon('Two-Factor Authentication'),
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Data & Storage
              _buildSection(
                'Data & Storage',
                [
                  _buildSwitchTile(
                    'Auto Backup',
                    'Automatically backup your data',
                    Icons.backup_outlined,
                    _autoBackup,
                    (value) => setState(() => _autoBackup = value),
                  ),
                  _buildActionTile(
                    'Clear Cache',
                    'Free up storage space',
                    Icons.cleaning_services_outlined,
                    () => _showClearCacheDialog(),
                  ),
                  _buildActionTile(
                    'Export Data',
                    'Download your account data',
                    Icons.download_outlined,
                    () => _showComingSoon('Export Data'),
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Privacy
              _buildSection(
                'Privacy',
                [
                  _buildActionTile(
                    'Privacy Policy',
                    'Read our privacy policy',
                    Icons.privacy_tip_outlined,
                    () => _showComingSoon('Privacy Policy'),
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'View terms and conditions',
                    Icons.description_outlined,
                    () => _showComingSoon('Terms of Service'),
                  ),
                  _buildActionTile(
                    'Delete Account',
                    'Permanently delete your account',
                    Icons.delete_forever_outlined,
                    () => _showDeleteAccountDialog(),
                    isDestructive: true,
                  ),
                ],
              ),
        
              // SizedBox(height: 32.h),
        
              // // Save Button
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: _saveSettings,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: colorScheme.primary,
              //       foregroundColor: colorScheme.onPrimary,
              //       padding: EdgeInsets.symmetric(vertical: 16.h),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12.r),
              //       ),
              //       elevation: 0,
              //       textStyle: theme.textTheme.labelLarge?.copyWith(
              //         fontSize: 16.sp,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //     child: Text(
              //       'Save Settings',
              //       style: theme.textTheme.labelLarge?.copyWith(
              //         fontSize: 16.sp,
              //         fontWeight: FontWeight.w600,
              //         color: colorScheme.onPrimary,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              final isLast = index == children.length - 1;
              
              return Column(
                children: [
                  child,
                  if (!isLast)
                    Divider(
                      height: 1.h,
                      indent: 56.w,
                      endIndent: 16.w,
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surface,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final iconColor = isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;
    final textColor = isDestructive ? theme.colorScheme.error : null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: textColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDestructive
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, ThemeState themeState) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.palette_outlined,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Choose your preferred theme',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<ThemeMode>(
            value: themeState.themeMode,
            onChanged: (ThemeMode? newMode) {
              if (newMode != null) {
                context.read<ThemeCubit>().setThemeMode(newMode);
              }
            },
            underline: const SizedBox(),
            dropdownColor: theme.colorScheme.surface,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            items: [
              DropdownMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.brightness_auto, size: 16.sp, color: theme.colorScheme.onSurface),
                    SizedBox(width: 8.w),
                    Text(
                      'System',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.light_mode, size: 16.sp, color: theme.colorScheme.onSurface),
                    SizedBox(width: 8.w),
                    Text(
                      'Light',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dark_mode, size: 16.sp, color: theme.colorScheme.onSurface),
                    SizedBox(width: 8.w),
                    Text(
                      'Dark',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Settings saved successfully!'),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text('The $feature feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('This feature will redirect you to a secure password change page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Change Password');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data and may improve app performance. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully!'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            const Text('Delete Account'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete your account?',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'This will permanently delete:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            ...['Your profile and personal data', 'Your order history', 'Your cart and wishlist', 'All saved addresses']
                .map((item) => Padding(
                      padding: EdgeInsets.only(left: 16.w, bottom: 4.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 6.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onErrorContainer,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isDeleting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isDeleting ? null : () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: _isDeleting
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onError,
                      ),
                    ),
                  )
                : const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      final userId = user.uid;
      final userEmail = user.email;

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  'Deleting your account...',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            ),
          ),
        );
      }

      // Delete user data from Firestore FIRST (before deleting Firebase user)
      try {
        await _cartService.clearCart(userId);
      } catch (e) {
        print('Warning: Failed to clear cart: $e');
      }
      
      try {
        await _wishlistService.clearWishlist(userId);
      } catch (e) {
        print('Warning: Failed to clear wishlist: $e');
      }
      
      try {
        await _userService.deleteUserProfile(userId);
      } catch (e) {
        print('Warning: Failed to delete user profile: $e');
      }
      
      // Clear local data
      try {
        await _userDataManager.clearLocalUserData();
      } catch (e) {
        print('Warning: Failed to clear local data: $e');
      }

      // Now delete the Firebase user account
      try {
        await user.delete();
        
        // Close loading dialog immediately after successful deletion
        if (mounted) {
          Navigator.pop(context);
        }
        
        // Force logout through AuthCubit to ensure proper state management
        if (mounted) {
          final authCubit = context.read<AuthCubit>();
          await authCubit.logout();
        }
        
        // Navigate to login screen after logout
        if (mounted) {
          // Use go_router to navigate to login
          context.go('/login');
          
          // Show success message
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deleted successfully'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
        }
        
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Handle re-authentication requirement
          if (mounted) {
            Navigator.pop(context); // Close loading dialog
          }
          
          // Show re-authentication dialog
          final shouldReauth = await _showReauthDialog();
          if (!shouldReauth) {
            setState(() {
              _isDeleting = false;
            });
            return;
          }

          // Show loading dialog again
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Deleting your account...',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            );
          }

          // Try to delete again after re-authentication
          await user.delete();
          
          // Close loading dialog after successful deletion
          if (mounted) {
            Navigator.pop(context);
          }
          
          // Force logout through AuthCubit
          if (mounted) {
            final authCubit = context.read<AuthCubit>();
            await authCubit.logout();
          }
          
          // Navigate to login screen
          if (mounted) {
            context.go('/login');
            
            // Show success message
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Account deleted successfully'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            });
          }
        } else {
          rethrow;
        }
      }
    } on FirebaseAuthException catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        Navigator.pop(context);
      }

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'User account not found.';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection and try again.';
          break;
        default:
          errorMessage = 'Failed to delete account: ${e.message}';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                const Text('Deletion Failed'),
              ],
            ),
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) {
        Navigator.pop(context);
      }

      // Show error message
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                const Text('Deletion Failed'),
              ],
            ),
            content: Text(
              'Failed to delete account: ${e.toString()}',
              style: TextStyle(fontSize: 14.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<bool> _showReauthDialog() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.security_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            const Text('Security Check'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For security reasons, we need to verify your identity before deleting your account.',
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'Please sign out and sign back in, then try deleting your account again.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, true);
              // Sign out the user
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    ) ?? false;
  }

}