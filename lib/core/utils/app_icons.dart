import 'package:flutter/material.dart';

/// Maps the category `icon` value stored in Supabase to a Material icon.
class AppIcons {
  const AppIcons._();

  static IconData category(String? name) {
    return switch (name) {
      'headphones' => Icons.headphones_rounded,
      'watch' => Icons.watch_rounded,
      'bag' => Icons.shopping_bag_rounded,
      'home' => Icons.chair_rounded,
      'footwear' => Icons.directions_run_rounded,
      'eyewear' => Icons.remove_red_eye_rounded,
      'skincare' => Icons.spa_rounded,
      'tech' => Icons.devices_rounded,
      _ => Icons.category_rounded,
    };
  }
}
