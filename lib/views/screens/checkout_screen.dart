import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/price_formatter.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../viewmodels/auth_cubit.dart';
import '../../viewmodels/order_cubit.dart';
import '../../widgets/cart_icon_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartCubit>();
    final orderCubit = context.read<OrderCubit>();
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), actions: const [CartIconButton()]),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrderCubit, OrderState>(
            listener: (context, state) {
              if (state is OrderCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order ${state.order.id} placed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                cart.clear();
                context.go('/home');
              } else if (state is OrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    final items = state.items.values.toList();
                    if (items.isEmpty) {
                      return const Center(child: Text('No items to checkout'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return ListTile(
                          title: Text(item.product.name),
                          subtitle: Text('Qty: ${item.quantity}'),
                          trailing: Text(PriceFormatter.format(item.totalPrice)),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  Text(PriceFormatter.format(cart.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              BlocBuilder<OrderCubit, OrderState>(
                builder: (context, orderState) {
                  final isLoading = orderState is OrderLoading;
                  
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading ? null : () async {
                        if (cart.itemCount == 0) return;
                        
                        final authState = authCubit.state;
                        if (authState is AuthAuthenticated) {
                          await orderCubit.createOrder(
                            cartItems: cart.state.items,
                            userId: authState.user.id,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to place an order'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Place Order'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
