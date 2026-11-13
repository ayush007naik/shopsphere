import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Editorial promotion card on the home dashboard.
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        color: AppColors.primary,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: 172,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryLight, AppColors.primary],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -46,
                  top: -54,
                  child: _Circle(
                    size: 190,
                    color: AppColors.accent.withValues(alpha: 0.22),
                  ),
                ),
                Positioned(
                  right: 34,
                  bottom: -58,
                  child: _Circle(
                    size: 130,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THE SEASONAL EDIT',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppColors.accent.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Quiet luxury,\nconsidered prices.',
                        style: TextStyle(
                          fontFamily: 'DMSerifDisplay',
                          fontSize: 25,
                          height: 1.12,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore the edit',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
