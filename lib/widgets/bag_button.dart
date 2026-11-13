import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/bag_provider.dart';
import 'bag_sheet.dart';

/// Bag shortcut with a live item-count badge.
class BagButton extends StatelessWidget {
  const BagButton({super.key, this.background = AppColors.surface});

  final Color background;

  @override
  Widget build(BuildContext context) {
    return Consumer<BagProvider>(
      builder: (context, bag, _) {
        final count = bag.itemCount;
        return SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: background,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => showBagSheet(context),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ),
              ),
              if (count > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 19,
                      minHeight: 19,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        count > 9 ? '9+' : '$count',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.5,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
