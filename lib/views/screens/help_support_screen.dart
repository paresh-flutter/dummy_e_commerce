import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
              // Quick Actions
              _buildSection(
                'Quick Actions',
                [
                  _buildActionTile(
                    'Contact Support',
                    'Get help from our support team',
                    Icons.support_agent_outlined,
                    Theme.of(context).colorScheme.primary,
                    () => _showContactOptions(context),
                    context,
                  ),
                  _buildActionTile(
                    'Live Chat',
                    'Chat with us in real-time',
                    Icons.chat_outlined,
                    Theme.of(context).colorScheme.tertiary,
                    () => _showComingSoon(context, 'Live Chat'),
                    context,
                  ),
                  _buildActionTile(
                    'Report a Problem',
                    'Let us know about any issues',
                    Icons.report_problem_outlined,
                    Theme.of(context).colorScheme.secondary,
                    () => _showReportProblemDialog(context),
                    context,
                  ),
                ],
                context,
              ),
        
              SizedBox(height: 24.h),
        
              // FAQ Categories
              _buildSection(
                'Frequently Asked Questions',
                [
                  _buildActionTile(
                    'Account & Profile',
                    'Questions about your account',
                    Icons.account_circle_outlined,
                    Theme.of(context).colorScheme.primary,
                    () => _showFAQCategory(context, 'Account & Profile'),
                    context,
                  ),
                  _buildActionTile(
                    'Orders & Shipping',
                    'Track orders and shipping info',
                    Icons.local_shipping_outlined,
                    Theme.of(context).colorScheme.secondary,
                    () => _showFAQCategory(context, 'Orders & Shipping'),
                    context,
                  ),
                  _buildActionTile(
                    'Payments & Refunds',
                    'Payment methods and refund policy',
                    Icons.payment_outlined,
                    Theme.of(context).colorScheme.tertiary,
                    () => _showFAQCategory(context, 'Payments & Refunds'),
                    context,
                  ),
                  _buildActionTile(
                    'App Usage',
                    'How to use the app features',
                    Icons.help_outline,
                    Theme.of(context).colorScheme.primary,
                    () => _showFAQCategory(context, 'App Usage'),
                    context,
                  ),
                ],
                context,
              ),
        
              SizedBox(height: 24.h),
        
              // Resources
              _buildSection(
                'Resources',
                [
                  _buildActionTile(
                    'User Guide',
                    'Complete guide to using our app',
                    Icons.menu_book_outlined,
                    Colors.brown,
                    () => _showComingSoon(context, 'User Guide'),
                    context,
                  ),
                  _buildActionTile(
                    'Video Tutorials',
                    'Watch helpful video guides',
                    Icons.play_circle_outline,
                    Colors.red,
                    () => _showComingSoon(context, 'Video Tutorials'),
                    context,
                  ),
                  _buildActionTile(
                    'Community Forum',
                    'Connect with other users',
                    Icons.forum_outlined,
                    Colors.deepPurple,
                    () => _showComingSoon(context, 'Community Forum'),
                    context,
                  ),
                ],
                context,
              ),
        
              SizedBox(height: 32.h),
        
              // Contact Information Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      color: colorScheme.onPrimary,
                      size: 32.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Need More Help?',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Our support team is available 24/7 to help you with any questions or concerns.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(alpha: 0.9),
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildContactButton(
                          'Email',
                          Icons.email_outlined,
                          () => _launchEmail(context),
                        ),
                        _buildContactButton(
                          'Phone',
                          Icons.phone_outlined,
                          () => _launchPhone(context),
                        ),
                        _buildContactButton(
                          'Website',
                          Icons.web_outlined,
                          () => _launchWebsite(context),
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
    );
  }

  Widget _buildSection(String title, List<Widget> children, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
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
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
    BuildContext context,
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildContactButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email Support'),
              subtitle: const Text('support@example.com'),
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone Support'),
              subtitle: const Text('+1 (555) 123-4567'),
              onTap: () {
                Navigator.pop(context);
                _launchPhone(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: const Text('Live Chat'),
              subtitle: const Text('Available 24/7'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoon(context, 'Live Chat');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQCategory(BuildContext context, String category) {
    final faqs = _getFAQsForCategory(category);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Text(
                          faq['answer']!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Problem'),
        content: const Text('Please describe the issue you\'re experiencing and we\'ll get back to you as soon as possible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon(context, 'Problem Reporting');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  void _launchEmail(BuildContext context) {
    _showComingSoon(context, 'Email Support');
  }

  void _launchPhone(BuildContext context) {
    _showComingSoon(context, 'Phone Support');
  }

  void _launchWebsite(BuildContext context) {
    _showComingSoon(context, 'Website Support');
  }

  List<Map<String, String>> _getFAQsForCategory(String category) {
    switch (category) {
      case 'Account & Profile':
        return [
          {
            'question': 'How do I update my profile information?',
            'answer': 'Go to Profile > Edit Profile to update your personal information, including name, email, and phone number.',
          },
          {
            'question': 'How do I change my password?',
            'answer': 'You can change your password in Settings > Security > Change Password.',
          },
          {
            'question': 'How do I delete my account?',
            'answer': 'Account deletion can be requested through Settings > Privacy > Delete Account. This action is permanent and cannot be undone.',
          },
        ];
      case 'Orders & Shipping':
        return [
          {
            'question': 'How can I track my order?',
            'answer': 'You can track your orders by going to Profile > My Orders and selecting the order you want to track.',
          },
          {
            'question': 'What are the shipping options?',
            'answer': 'We offer standard shipping (5-7 business days) and express shipping (2-3 business days).',
          },
          {
            'question': 'Can I change my shipping address?',
            'answer': 'You can change your shipping address before the order is processed. Contact support if you need to change it after processing.',
          },
        ];
      case 'Payments & Refunds':
        return [
          {
            'question': 'What payment methods do you accept?',
            'answer': 'We accept all major credit cards, PayPal, and digital wallets like Apple Pay and Google Pay.',
          },
          {
            'question': 'How do I request a refund?',
            'answer': 'Refunds can be requested within 30 days of purchase. Go to My Orders and select "Request Refund" for eligible items.',
          },
          {
            'question': 'When will I receive my refund?',
            'answer': 'Refunds are typically processed within 5-7 business days after approval.',
          },
        ];
      case 'App Usage':
        return [
          {
            'question': 'How do I add items to my wishlist?',
            'answer': 'Tap the heart icon on any product to add it to your wishlist. You can view your wishlist from the main navigation.',
          },
          {
            'question': 'How do I use filters when searching?',
            'answer': 'Use the filter icon in the search results to narrow down products by price, brand, rating, and other criteria.',
          },
          {
            'question': 'How do I enable notifications?',
            'answer': 'Go to Profile > Notifications to customize which notifications you want to receive.',
          },
        ];
      default:
        return [];
    }
  }
}