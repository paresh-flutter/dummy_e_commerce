import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'About',
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
              // App Logo and Info
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 20.r,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        size: 48.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'E-Commerce App',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Your one-stop shop for everything you need',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
        
              SizedBox(height: 32.h),
        
              // App Information
              _buildSection(
                'App Information',
                [
                  _buildInfoTile(
                    'Version',
                    '1.0.0 (Build 1)',
                    Icons.info_outline,
                    Colors.blue,
                  ),
                  _buildInfoTile(
                    'Release Date',
                    'November 2024',
                    Icons.calendar_today_outlined,
                    Colors.green,
                  ),
                  _buildInfoTile(
                    'Size',
                    '45.2 MB',
                    Icons.storage_outlined,
                    Colors.orange,
                  ),
                  _buildInfoTile(
                    'Platform',
                    'iOS & Android',
                    Icons.phone_android_outlined,
                    Colors.purple,
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Features
              _buildSection(
                'Key Features',
                [
                  _buildFeatureTile(
                    'Browse Products',
                    'Discover thousands of products across multiple categories',
                    Icons.search_outlined,
                    Colors.teal,
                  ),
                  _buildFeatureTile(
                    'Secure Payments',
                    'Safe and secure payment processing with multiple options',
                    Icons.security_outlined,
                    Colors.indigo,
                  ),
                  _buildFeatureTile(
                    'Order Tracking',
                    'Real-time tracking of your orders from purchase to delivery',
                    Icons.local_shipping_outlined,
                    Colors.cyan,
                  ),
                  _buildFeatureTile(
                    'Wishlist',
                    'Save your favorite items for later purchase',
                    Icons.favorite_outline,
                    Colors.red,
                  ),
                ],
              ),
        
              SizedBox(height: 24.h),
        
              // Company Information
              _buildSection(
                'Company',
                [
                  _buildActionTile(
                    'Our Story',
                    'Learn about our journey and mission',
                    Icons.business_outlined,
                    Colors.brown,
                    () => _showOurStory(context),
                  ),
                  _buildActionTile(
                    'Privacy Policy',
                    'Read our privacy policy and data handling',
                    Icons.privacy_tip_outlined,
                    Colors.deepPurple,
                    () => _showComingSoon(context, 'Privacy Policy'),
                  ),
                  _buildActionTile(
                    'Terms of Service',
                    'View our terms and conditions',
                    Icons.description_outlined,
                    colorScheme.onSurfaceVariant,
                    () => _showComingSoon(context, 'Terms of Service'),
                  ),
                  _buildActionTile(
                    'Licenses',
                    'Open source licenses and attributions',
                    Icons.code_outlined,
                    Colors.pink,
                    () => _showLicenses(context),
                  ),
                ],
              ),
        
              SizedBox(height: 32.h),
        
              // Footer
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
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
                    Text(
                      'Made with ❤️ by Our Team',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '© 2024 E-Commerce App. All rights reserved.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
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

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
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
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
    String title,
    String description,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOurStory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Our Story'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Founded in 2024, our e-commerce platform was born from a simple idea: to make online shopping more accessible, secure, and enjoyable for everyone.',
                style: TextStyle(fontSize: 14.sp, height: 1.4),
              ),
              SizedBox(height: 12.h),
              Text(
                'We believe that technology should simplify life, not complicate it. That\'s why we\'ve built an app that focuses on user experience, security, and reliability.',
                style: TextStyle(fontSize: 14.sp, height: 1.4),
              ),
              SizedBox(height: 12.h),
              Text(
                'Today, we serve thousands of customers worldwide, offering a curated selection of products with fast, reliable delivery and exceptional customer service.',
                style: TextStyle(fontSize: 14.sp, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Source Licenses'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This app uses the following open source packages:',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12.h),
              _buildLicenseItem('Flutter', 'BSD-3-Clause License'),
              _buildLicenseItem('flutter_bloc', 'MIT License'),
              _buildLicenseItem('flutter_screenutil', 'Apache License 2.0'),
              _buildLicenseItem('go_router', 'BSD-3-Clause License'),
              _buildLicenseItem('equatable', 'MIT License'),
              SizedBox(height: 12.h),
              Text(
                'We are grateful to the open source community for their contributions.',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(String package, String license) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 14.sp)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                children: [
                  TextSpan(
                    text: package,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' - $license'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}