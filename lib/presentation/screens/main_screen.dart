import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import '../../core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NavigationProvider>().setIndex(widget.initialIndex);
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final selectedIndex = navigationProvider.selectedIndex;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => navigationProvider.setIndex(index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Badge(
                  label: Text(cart.cart.itemCount.toString()),
                  isLabelVisible: cart.cart.itemCount > 0,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.shopping_cart_outlined),
                );
              },
            ),
            activeIcon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Badge(
                  label: Text(cart.cart.itemCount.toString()),
                  isLabelVisible: cart.cart.itemCount > 0,
                  backgroundColor: AppTheme.accentColor,
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: 'Cart',
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
}
