import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/bag_item.dart';
import '../providers/bag_provider.dart';
import 'product_image.dart';
import 'quantity_stepper.dart';

Future<void> showBagSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    barrierColor: AppColors.ink.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const BagSheet(),
  );
}

/// Bottom sheet showing the locally persisted bag. No checkout is included.
class BagSheet extends StatelessWidget {
  const BagSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BagProvider>(
      builder: (context, bag, _) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 10, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your bag',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 24),
                            ),
                            Text(
                              bag.itemCount == 1
                                  ? '1 item'
                                  : '${bag.itemCount} items',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (!bag.isEmpty)
                        TextButton(
                          onPressed: bag.clear,
                          child: const Text('Clear'),
                        ),
                      IconButton(
                        tooltip: 'Close bag',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
                if (bag.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 28),
                    child: _EmptyBag(),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                      itemCount: bag.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = bag.items[index];
                        return _BagRow(item: item);
                      },
                    ),
                  ),
                if (!bag.isEmpty) _BagSummary(bag: bag),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BagRow extends StatelessWidget {
  const _BagRow({required this.item});

  final BagItem item;

  @override
  Widget build(BuildContext context) {
    final bag = context.read<BagProvider>();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 62,
              height: 62,
              child: ProductImage(
                url: item.product.imageUrl,
                semanticLabel: item.product.name,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatPrice(item.lineTotal),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            children: [
              IconButton(
                tooltip: 'Remove item',
                onPressed: () => bag.remove(item.product.id),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 30,
                  minHeight: 28,
                ),
              ),
              const SizedBox(height: 4),
              QuantityStepper(
                value: item.quantity,
                compact: true,
                onDecrement: () => bag.setQuantity(
                  item.product.id,
                  item.quantity - 1,
                ),
                onIncrement: () => bag.setQuantity(
                  item.product.id,
                  item.quantity + 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BagSummary extends StatelessWidget {
  const _BagSummary({required this.bag});

  final BagProvider bag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const Spacer(),
                Text(
                  formatPrice(bag.subtotal),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Saved on this device. Checkout is not part of this demo.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue shopping'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyBag extends StatelessWidget {
  const _EmptyBag();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 28,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your bag is empty',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 21,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pieces you add will be saved here on this device.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
