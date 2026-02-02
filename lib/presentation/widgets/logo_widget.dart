import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final bool showText;

  final Color? textColor;

  const LogoWidget({
    super.key,
    this.size = 80,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon/Circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.accentColor,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: AppTheme.white,
            size: size * 0.5,
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            AppConstants.appName,
            style: AppTheme.headline2.copyWith(
              color: textColor ?? AppTheme.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Premium Shopping Experience',
            style: AppTheme.bodyText2.copyWith(
              color: textColor?.withOpacity(0.7) ?? AppTheme.grey,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ],
    );
  }
}


