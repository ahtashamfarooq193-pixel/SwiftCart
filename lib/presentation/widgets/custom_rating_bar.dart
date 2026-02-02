import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int count;
  final Color? color;
  final bool isReadOnly;
  final Function(double)? onRatingUpdate;

  const CustomRatingBar({
    super.key,
    required this.rating,
    this.size = 24,
    this.count = 5,
    this.color,
    this.isReadOnly = true,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        IconData icon;
        if (index >= rating) {
          icon = Icons.star_border;
        } else if (index > rating - 1 && index < rating) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!isReadOnly && onRatingUpdate != null) {
              print('CustomRatingBar: Tapped star index $index');
              onRatingUpdate!(index + 1.0);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * 0.1),
            child: Icon(
              icon,
              size: size,
              color: color ?? AppTheme.accentColor,
            ),
          ),
        );
      }),
    );
  }
}
