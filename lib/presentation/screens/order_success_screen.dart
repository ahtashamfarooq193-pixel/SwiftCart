import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'main_screen.dart';
import 'my_orders_screen.dart';
import '../../data/models/mock_data.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.successColor,
                        size: 100,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: AppTheme.headline2.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Your payment has been initiated. Our team will verify the Transaction ID (TID) and update your order status shortly.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyText2.copyWith(color: AppTheme.grey, height: 1.5),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.white.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order Verification',
                      style: AppTheme.bodyText1.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verification usually takes 30-60 minutes during business hours.',
                      textAlign: TextAlign.center,
                      style: AppTheme.caption.copyWith(color: AppTheme.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Track My Order',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersScreen(),
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
