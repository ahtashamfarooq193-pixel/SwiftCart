import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/cart_provider.dart';
import '../../domain/entities/cart.dart';
import 'main_screen.dart';
import 'shipping_details_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text('Your Premium Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cart.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => cartProvider.clearCart(),
                icon: const Icon(Icons.delete_outline, color: AppTheme.accentColor),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final cart = cartProvider.cart;

          if (cart.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return _buildCartItem(context, item, cartProvider);
                  },
                ),
              ),
              _buildCartSummary(context, cart),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppTheme.accentColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: AppTheme.headline3.copyWith(color: AppTheme.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Explore our luxury collection and add\nitems to your cart.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyText2.copyWith(color: AppTheme.grey),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 250,
            child: CustomButton(
              text: 'Start Shopping',
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/main');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Item Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              item.product.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTheme.bodyText1.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.selectedSize} | ${item.selectedColor}',
                  style: AppTheme.caption.copyWith(color: AppTheme.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rs ${item.product.price.round()}',
                  style: AppTheme.bodyText2.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Quantity Controls
          Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => provider.updateQuantity(item.id, item.quantity + 1),
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.accentColor, size: 28),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.quantity}',
                style: AppTheme.bodyText1.copyWith(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => provider.updateQuantity(item.id, item.quantity - 1),
                icon: const Icon(Icons.remove_circle_outline, color: AppTheme.grey, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, Cart cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTheme.bodyText2.copyWith(color: AppTheme.grey)),
                Text('Rs ${cart.subtotal.round()}', style: AppTheme.bodyText2.copyWith(color: AppTheme.white)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: AppTheme.bodyText2.copyWith(color: AppTheme.grey)),
                Text('Rs ${cart.shipping.round()}', style: AppTheme.bodyText1.copyWith(color: AppTheme.white)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white12),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTheme.headline3.copyWith(color: AppTheme.white)),
                Text(
                  'Rs ${cart.total.round()}',
                  style: AppTheme.headline3.copyWith(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Proceed to Checkout',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShippingDetailsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
