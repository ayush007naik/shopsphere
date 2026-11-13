import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Compact quantity control used on the product details and bag sheet.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
    this.compact = false,
  });

  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonSize = compact ? 28.0 : 36.0;
    final iconSize = compact ? 15.0 : 17.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            size: buttonSize,
            iconSize: iconSize,
            enabled: value > 1,
            onTap: onDecrement,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: compact ? 26 : 34),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            size: buttonSize,
            iconSize: iconSize,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: iconSize,
          color: enabled ? AppColors.ink : AppColors.border,
        ),
      ),
    );
  }
}
