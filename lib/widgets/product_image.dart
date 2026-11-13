import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

/// Network product image with graceful loading and failure placeholders.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String url;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) {
      return const _FallbackPlaceholder();
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 900,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (context, _) => const _LoadingPlaceholder(),
        errorWidget: (context, _, _) => const _FallbackPlaceholder(),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.imagePlaceholder),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _FallbackPlaceholder extends StatelessWidget {
  const _FallbackPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.imagePlaceholder),
      alignment: Alignment.center,
      child: const Icon(
        Icons.photo_outlined,
        size: 30,
        color: AppColors.muted,
      ),
    );
  }
}
