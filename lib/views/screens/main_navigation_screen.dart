import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/cart_cubit.dart';
import '../../viewmodels/wishlist_cubit.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        actions: _getAppBarActions(),
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          HomeScreen(showAppBar: false),
          CartScreen(showAppBar: false),
          WishlistScreen(showAppBar: false),
          ProfileScreen(showAppBar: false),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state.items.length;
                return Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text(itemCount.toString()),
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            activeIcon: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state.items.length;
                return Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text(itemCount.toString()),
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) {
                final itemCount = state.items.length;
                return Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text(itemCount.toString()),
                  child: const Icon(Icons.favorite_outline),
                );
              },
            ),
            activeIcon: BlocBuilder<WishlistCubit, WishlistState>(
              builder: (context, state) {
                final itemCount = state.items.length;
                return Badge(
                  isLabelVisible: itemCount > 0,
                  label: Text(itemCount.toString()),
                  child: const Icon(Icons.favorite),
                );
              },
            ),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Store';
      case 1:
        return 'Shopping Cart';
      case 2:
        return 'Wishlist';
      case 3:
        return 'Profile';
      default:
        return 'Store';
    }
  }

  List<Widget>? _getAppBarActions() {
    switch (_currentIndex) {
      case 0: // Home screen actions
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Focus on search field in home screen
              // This could be implemented with a focus node
            },
            tooltip: 'Search',
          ),
        ];
      case 1: // Cart screen actions
        return [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Clear cart action
              _showClearCartDialog();
            },
            tooltip: 'Clear Cart',
          ),
        ];
      case 2: // Wishlist screen actions
        return [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              // Clear wishlist action
              _showClearWishlistDialog();
            },
            tooltip: 'Clear Wishlist',
          ),
        ];
      case 3: // Profile screen actions
        return [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
              context.push('/settings');
            },
            tooltip: 'Settings',
          ),
        ];
      default:
        return null;
    }
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartCubit>().clearCart();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cart cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearWishlistDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Wishlist'),
        content: const Text('Are you sure you want to remove all items from your wishlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<WishlistCubit>().clearWishlist();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
