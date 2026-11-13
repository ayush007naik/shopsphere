import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// The ShopSphere brand mark: a bag glyph with a terracotta seal.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 52,
    this.showWordmark = false,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onDark ? Colors.white : AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: size * 0.46,
            color: onDark ? AppColors.primary : Colors.white,
          ),
          Positioned(
            right: size * 0.23,
            bottom: size * 0.22,
            child: Container(
              width: size * 0.14,
              height: size * 0.14,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.26),
        Text(
          'ShopSphere',
          style: TextStyle(
            fontFamily: 'DMSerifDisplay',
            fontSize: size * 0.52,
            height: 1,
            letterSpacing: -0.2,
            color: onDark ? Colors.white : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
