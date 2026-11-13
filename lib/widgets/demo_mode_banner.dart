import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Clearly communicates that the app is using the bundled demo catalogue.
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 9 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: AppColors.accent,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              compact
                  ? 'Demo catalogue · add Supabase keys for live data.'
                  : 'Offline demo mode. Add your Supabase URL and publishable '
                        'key to connect the live catalogue and authentication.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.ink.withValues(alpha: 0.78),
                fontSize: compact ? 10.5 : 11.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
