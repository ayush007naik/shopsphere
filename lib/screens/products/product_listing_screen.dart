import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/app_icons.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/bag_button.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_views.dart';

/// Searchable, category-filterable product listing with loading, error and
/// empty states.
class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({
    super.key,
    this.initialCategoryId,
    this.initialQuery,
  });

  final String? initialCategoryId;
  final String? initialQuery;

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductProvider>().openListing(
        categoryId: widget.initialCategoryId,
        query: widget.initialQuery,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    context.read<ProductProvider>().submitSearch('');
  }

  void _resetFilters() {
    _searchController.clear();
    FocusScope.of(context).unfocus();
    context.read<ProductProvider>().resetFilters();
  }

  void _applyRecentSearch(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.collapsed(
      offset: term.length,
    );
    FocusScope.of(context).unfocus();
    context.read<ProductProvider>().submitSearch(term);
  }

  void _openProduct(Product product) {
    Navigator.of(context).pushNamed(
      AppRoutes.productDetails,
      arguments: product,
    );
  }

  SliverGridDelegate _gridDelegate(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900
        ? 4
        : width >= 620
        ? 3
        : 2;
    final ratio = crossAxisCount == 2
        ? 0.60
        : crossAxisCount == 3
        ? 0.66
        : 0.70;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: ratio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('The collection'),
        actions: const [BagButton(), SizedBox(width: 16)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: AppSearchField(
                controller: _searchController,
                onChanged: products.onSearchChanged,
                onSubmitted: (value) {
                  FocusScope.of(context).unfocus();
                  products.submitSearch(value);
                },
                showClear: products.query.isNotEmpty,
                onClear: _clearSearch,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.categories.length + 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = index == 0
                      ? null
                      : products.categories[index - 1];
                  final selected =
                      products.selectedCategoryId == category?.id;
                  return ChoiceChip(
                    selected: selected,
                    onSelected: (_) => products.selectCategory(category?.id),
                    avatar: category == null
                        ? null
                        : Icon(
                            AppIcons.category(category.icon),
                            size: 15,
                            color: selected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                    label: Text(category?.name ?? 'All'),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: selected ? Colors.white : AppColors.ink,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  );
                },
              ),
            ),
            if (products.query.trim().isEmpty &&
                products.recentSearches.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          size: 15,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'RECENT SEARCHES',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontSize: 8.5, letterSpacing: 1.3),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: products.clearSearchHistory,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 28),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.muted,
                          ),
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: products.recentSearches
                          .map(
                            (term) => ActionChip(
                              label: Text(term),
                              onPressed: () => _applyRecentSearch(term),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              labelStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: AppColors.ink,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults(context, products)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, ProductProvider products) {
    if (products.isLoadingProducts) {
      return const LoadingView(message: 'Finding pieces for you…');
    }

    if (products.productsError != null) {
      return ErrorStateView(
        message: products.productsError!,
        onRetry: products.retryListing,
      );
    }

    if (products.products.isEmpty) {
      final hasFilters = products.hasActiveFilters;
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: products.query.trim().isEmpty
            ? 'Nothing here yet'
            : 'No matches found',
        message: products.query.trim().isEmpty
            ? 'This part of the collection is being updated. Try another '
                  'category or refresh.'
            : 'We could not find anything for “${products.query.trim()}”. '
                  'Try a different keyword or explore another category.',
        actionLabel: hasFilters ? 'Reset filters' : 'Refresh',
        onAction: hasFilters
            ? _resetFilters
            : () => products.fetchListing(),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: products.fetchListing,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        gridDelegate: _gridDelegate(context),
        itemCount: products.products.length,
        itemBuilder: (context, index) {
          final product = products.products[index];
          return ProductCard(
            product: product,
            onTap: () => _openProduct(product),
          );
        },
      ),
    );
  }
}
