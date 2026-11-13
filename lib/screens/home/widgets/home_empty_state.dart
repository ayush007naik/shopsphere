import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Shown when the home catalogue loads successfully but contains no products.
class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 30,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'The shelves are being restocked',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'New pieces will appear here as soon as they are published.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: onRetry, child: const Text('Refresh')),
        ],
      ),
    );
  }
}
