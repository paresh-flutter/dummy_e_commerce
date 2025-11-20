import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/order.dart';
import '../../models/address.dart';
import '../../utils/price_formatter.dart';
import '../../viewmodels/order_cubit.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.share_outlined, size: 22.sp),
          //   onPressed: () => _shareOrder(context),
          // ),
          // SizedBox(width: 4.w),
        ],
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoaded) {
            final order = state.orders.firstWhere(
                  (o) => o.id == orderId,
              orElse: () => throw Exception('Order not found'),
            );
            return _buildOrderDetails(context, order, colorScheme);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Order order, ColorScheme colorScheme) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header Card
            _buildOrderHeader(order, colorScheme, context),
      
            SizedBox(height: 16.h),
      
            // Order Tracking Section
            _buildOrderTracking(context, order, colorScheme),
      
            SizedBox(height: 16.h),
      
            // Order Items
            _buildOrderItems(order, colorScheme),
      
            SizedBox(height: 16.h),
      
            // Shipping Address
            if (order.shippingAddress != null)
              _buildShippingAddress(order.shippingAddress!, colorScheme),
      
            SizedBox(height: 16.h),
      
            // Payment Details
            if (order.paymentDetails != null)
              _buildPaymentDetails(order.paymentDetails!, colorScheme),
      
            SizedBox(height: 16.h),
      
            // Order Summary
            _buildOrderSummary(order, colorScheme),
      
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(Order order, ColorScheme colorScheme, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  order.statusDisplayName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(order.status),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),

          if (order.trackingNumber != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.local_shipping_outlined,
                      size: 18.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tracking ID',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          order.trackingNumber!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => _copyTrackingNumber(context, order.trackingNumber!),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.content_copy_rounded,
                        size: 16.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (order.estimatedDelivery != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 14.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 6.w),
                Text(
                  'Est. delivery: ${DateFormat('MMM dd, yyyy').format(order.estimatedDelivery!)}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderTracking(BuildContext context, Order order, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Tracking',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          // Progress indicator
          if (order.estimatedDelivery != null) ...[
            SizedBox(height: 20.h),
            _buildProgressIndicator(order, colorScheme),
          ],

          SizedBox(height: 24.h),

          // Timeline
          if (order.trackingHistory.isNotEmpty) ...[
            ...order.trackingHistory.asMap().entries.map((entry) {
              final index = entry.key;
              final tracking = entry.value;
              final isLast = index == order.trackingHistory.length - 1;
              final isActive = index == order.trackingHistory.length - 1;

              return _buildRealTrackingStep(tracking, isLast, isActive, colorScheme);
            }).toList(),
          ] else ...[
            ..._getTrackingSteps(order).asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isLast = index == _getTrackingSteps(order).length - 1;

              return _buildTrackingStep(step, isLast, colorScheme);
            }).toList(),
          ],

          // Estimated delivery banner
          if (order.estimatedDelivery != null && order.status != OrderStatus.delivered) ...[
            SizedBox(height: 20.h),
            _buildEstimatedDelivery(order, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Order order, ColorScheme colorScheme) {
    final progress = _getOrderProgress(order.status);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            height: 8.h,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingStep(TrackingStep step, bool isLast, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.h,
                decoration: BoxDecoration(
                  color: step.isCompleted
                      ? colorScheme.primary
                      : colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                  boxShadow: step.isCompleted ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8.r,
                      spreadRadius: 0,
                    ),
                  ] : null,
                ),
                child: step.isCompleted
                    ? Icon(Icons.check_rounded, size: 18.sp, color: colorScheme.onPrimary)
                    : null,
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 50.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: step.isCompleted
                          ? [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.3)]
                          : [colorScheme.surfaceContainer, colorScheme.surfaceContainerHigh],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: step.isCompleted ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                  ),
                ),
                if (step.description != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    step.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
                if (step.timestamp != null) ...[
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('MMM dd, hh:mm a').format(step.timestamp!),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTrackingStep(OrderTracking tracking, bool isLast, bool isActive, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.primary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: isActive ? 0.4 : 0.2),
                      blurRadius: isActive ? 12.r : 8.r,
                      spreadRadius: 0,
                    ),
                  ],
                  border: isActive ? Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 4.w,
                  ) : null,
                ),
                child: Icon(
                  _getTrackingIcon(tracking.status),
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2.w,
                  height: 60.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.primary.withValues(alpha: 0.5),
                        colorScheme.primary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isActive
                      ? colorScheme.primary.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _getStatusDisplayName(tracking.status),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: isActive ? colorScheme.primary : Colors.black87,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          DateFormat('MMM dd').format(tracking.timestamp),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isActive ? colorScheme.primary : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        DateFormat('hh:mm a').format(tracking.timestamp),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (tracking.description != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      tracking.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (tracking.location != null) ...[
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              tracking.location!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedDelivery(Order order, ColorScheme colorScheme) {
    final now = DateTime.now();
    final isOverdue = order.estimatedDelivery!.isBefore(now);
    final daysRemaining = order.estimatedDelivery!.difference(now).inDays;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverdue
              ? [Colors.red.shade50, Colors.red.shade100]
              : [Colors.green.shade50, Colors.green.shade100],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isOverdue ? Colors.red.shade300 : Colors.green.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
              size: 20.sp,
              color: isOverdue ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Delivery Delayed' : 'Estimated Delivery',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isOverdue ? Colors.red.shade800 : Colors.green.shade800,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(order.estimatedDelivery!),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isOverdue ? Colors.red.shade700 : Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isOverdue && daysRemaining >= 0) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                daysRemaining == 0 ? 'Today' : '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(Order order, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${order.totalItems}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          ...order.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == order.items.length - 1;

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60.w,
                      height: 60.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey.shade500,
                            size: 24.sp,
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
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6.r),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Qty: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    PriceFormatter.format(item.totalPrice),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShippingAddress(Address address, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 16.sp, color: Colors.grey.shade600),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        address.fullName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16.sp, color: Colors.grey.shade600),
                    SizedBox(width: 8.w),
                    Text(
                      address.phoneNumber,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.home_outlined, size: 16.sp, color: colorScheme.primary),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          address.formattedAddress,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(PaymentDetails payment, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.payment_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Payment Details',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        _getPaymentIcon(payment.method),
                        size: 24.sp,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.methodName,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (payment.cardLastFour != null) ...[
                            SizedBox(height: 3.h),
                            Text(
                              '•••• •••• •••• ${payment.cardLastFour}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      PriceFormatter.format(payment.amount),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 18.sp, color: Colors.green.shade600),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Paid on ${DateFormat('MMM dd, yyyy').format(payment.transactionDate)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Order order, ColorScheme colorScheme) {
    final subtotal = order.items.fold(0.0, (sum, item) => sum + item.totalPrice);
    final tax = subtotal * 0.1;
    final shipping = 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 20.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', subtotal, colorScheme),
                SizedBox(height: 10.h),
                _buildSummaryRow('Shipping', shipping, colorScheme, isFree: true),
                SizedBox(height: 10.h),
                _buildSummaryRow('Tax (10%)', tax, colorScheme),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(height: 1, color: Colors.grey.shade300),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      PriceFormatter.format(order.total),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ColorScheme colorScheme, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isFree ? 'FREE' : PriceFormatter.format(amount),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: isFree ? Colors.green.shade600 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange.shade600;
      case OrderStatus.confirmed:
        return Colors.blue.shade600;
      case OrderStatus.shipped:
        return Colors.purple.shade600;
      case OrderStatus.delivered:
        return Colors.green.shade600;
      case OrderStatus.cancelled:
        return Colors.red.shade600;
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return Icons.credit_card_rounded;
      case PaymentMethod.paypal:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.applePay:
        return Icons.phone_iphone_rounded;
    }
  }

  List<TrackingStep> _getTrackingSteps(Order order) {
    final steps = <TrackingStep>[];

    steps.add(TrackingStep(
      title: 'Order Placed',
      description: 'Your order has been received and is being processed',
      timestamp: order.orderDate,
      isCompleted: true,
    ));

    if (order.status.index >= OrderStatus.confirmed.index) {
      steps.add(TrackingStep(
        title: 'Order Confirmed',
        description: 'Your order has been confirmed and is being prepared',
        timestamp: order.orderDate.add(const Duration(hours: 2)),
        isCompleted: true,
      ));
    } else {
      steps.add(TrackingStep(
        title: 'Order Confirmed',
        description: 'Waiting for confirmation',
        isCompleted: false,
      ));
    }

    if (order.status.index >= OrderStatus.shipped.index) {
      steps.add(TrackingStep(
        title: 'Shipped',
        description: 'Your order is on its way',
        timestamp: order.orderDate.add(const Duration(days: 1)),
        isCompleted: true,
      ));
    } else {
      steps.add(TrackingStep(
        title: 'Shipped',
        description: 'Preparing for shipment',
        isCompleted: false,
      ));
    }

    if (order.status == OrderStatus.delivered) {
      steps.add(TrackingStep(
        title: 'Delivered',
        description: 'Your order has been delivered successfully',
        timestamp: order.orderDate.add(const Duration(days: 3)),
        isCompleted: true,
      ));
    } else if (order.status == OrderStatus.cancelled) {
      steps.add(TrackingStep(
        title: 'Cancelled',
        description: 'Your order has been cancelled',
        timestamp: DateTime.now(),
        isCompleted: true,
      ));
    } else {
      steps.add(TrackingStep(
        title: 'Delivered',
        description: 'Out for delivery',
        isCompleted: false,
      ));
    }

    return steps;
  }

  void _copyTrackingNumber(BuildContext context, String trackingNumber) {
    Clipboard.setData(ClipboardData(text: trackingNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'Tracking number copied!',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  void _shareOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Text(
              'Share functionality coming soon',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  double _getOrderProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.25;
      case OrderStatus.confirmed:
        return 0.5;
      case OrderStatus.shipped:
        return 0.75;
      case OrderStatus.delivered:
        return 1.0;
      case OrderStatus.cancelled:
        return 0.0;
    }
  }

  IconData _getTrackingIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_rounded;
      case OrderStatus.shipped:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.home_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _getStatusDisplayName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.shipped:
        return 'Package Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class TrackingStep {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final bool isCompleted;

  const TrackingStep({
    required this.title,
    this.description,
    this.timestamp,
    required this.isCompleted,
  });
}