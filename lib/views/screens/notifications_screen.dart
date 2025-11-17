import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _orderUpdates = true;
  bool _promotionalOffers = false;
  bool _newArrivals = true;
  bool _priceDrops = true;
  bool _wishlistUpdates = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // General Settings
              _buildSection(
                'General Settings',
                [
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive notifications on your device',
                    Icons.notifications_outlined,
                    _pushNotifications,
                    (value) => setState(() => _pushNotifications = value),
                  ),
                  _buildSwitchTile(
                    'Email Notifications',
                    'Receive notifications via email',
                    Icons.email_outlined,
                    _emailNotifications,
                    (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Order & Shopping
              _buildSection(
                'Order & Shopping',
                [
                  _buildSwitchTile(
                    'Order Updates',
                    'Get notified about order status changes',
                    Icons.shopping_bag_outlined,
                    _orderUpdates,
                    (value) => setState(() => _orderUpdates = value),
                  ),
                  _buildSwitchTile(
                    'Promotional Offers',
                    'Receive notifications about deals and discounts',
                    Icons.local_offer_outlined,
                    _promotionalOffers,
                    (value) => setState(() => _promotionalOffers = value),
                  ),
                  _buildSwitchTile(
                    'New Arrivals',
                    'Be the first to know about new products',
                    Icons.new_releases_outlined,
                    _newArrivals,
                    (value) => setState(() => _newArrivals = value),
                  ),
                  _buildSwitchTile(
                    'Price Drops',
                    'Get notified when prices drop on items you viewed',
                    Icons.trending_down_outlined,
                    _priceDrops,
                    (value) => setState(() => _priceDrops = value),
                  ),
                  _buildSwitchTile(
                    'Wishlist Updates',
                    'Notifications about your wishlist items',
                    Icons.favorite_outline,
                    _wishlistUpdates,
                    (value) => setState(() => _wishlistUpdates = value),
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Sound & Vibration
              _buildSection(
                'Sound & Vibration',
                [
                  _buildSwitchTile(
                    'Sound',
                    'Play sound for notifications',
                    Icons.volume_up_outlined,
                    _soundEnabled,
                    (value) => setState(() => _soundEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Vibration',
                    'Vibrate for notifications',
                    Icons.vibration_outlined,
                    _vibrationEnabled,
                    (value) => setState(() => _vibrationEnabled = value),
                  ),
                ],
              ),
        
              SizedBox(height: 32.h),
        
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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

  void _saveSettings() {
    // Here you would typically save the settings to your backend or local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification settings saved!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}