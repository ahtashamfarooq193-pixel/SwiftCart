import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool iconLeft;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.width,
    this.height = 50,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.iconLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isDisabled || isLoading || onPressed == null;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: disabled ? null : (backgroundColor == null ? AppTheme.amethystGradient : null),
        color: disabled ? AppTheme.grey.withOpacity(0.3) : (backgroundColor ?? AppTheme.accentColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: disabled
            ? null
            : [
                BoxShadow(
                  color: (backgroundColor ?? AppTheme.accentColor).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: textColor ?? AppTheme.primaryColor,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: AppTheme.grey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 24,
            vertical: 12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppTheme.primaryColor,
                  ),
                ),
              )
            else if (icon != null && iconLeft) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],

            Flexible(
              child: Text(
                text,
                style: AppTheme.button.copyWith(
                  color: disabled
                      ? AppTheme.grey
                      : (textColor ?? AppTheme.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (icon != null && !iconLeft) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.borderColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: disabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: borderColor ?? AppTheme.primaryColor,
            width: 2,
          ),
          foregroundColor: textColor ?? AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: icon != null ? 16 : 24,
            vertical: 12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppTheme.primaryColor,
                  ),
                ),
              )
            else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],

            Flexible(
              child: Text(
                text,
                style: AppTheme.button.copyWith(
                  color: disabled
                      ? AppTheme.grey
                      : (textColor ?? AppTheme.primaryColor),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppTheme.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: textColor ?? AppTheme.primaryColor,
        ),
      ),
    );
  }
}
