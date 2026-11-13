import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/bag_button.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/demo_mode_banner.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';
import 'widgets/home_empty_state.dart';
import 'widgets/home_error_banner.dart';
import 'widgets/promo_banner.dart';

/// The ShopSphere dashboard: greeting, search, categories, featured picks and
/// the newest arrivals. All content is loaded from the repository layer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final products = context.read<ProductProvider>();
      if (products.categories.isEmpty) {
        products.loadHome();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openListing({String? categoryId, String? query}) {
    Navigator.of(context).pushNamed(
      AppRoutes.products,
      arguments: ProductListingArgs(categoryId: categoryId, query: query),
    );
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    FocusScope.of(context).unfocus();
    _openListing(query: query.isEmpty ? null : query);
  }

  void _openAccount() {
    Navigator.of(context).pushNamed(AppRoutes.account);
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
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final hasData = products.categories.isNotEmpty;
    final greeting = greetingForHour(DateTime.now().hour);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => products.loadHome(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontSize: 9.5,
                                    letterSpacing: 1.6,
                                    color: AppColors.muted,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              auth.user?.firstName ?? 'Shopper',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontSize: 27),
                            ),
                          ],
                        ),
                      ),
                      const BagButton(),
                      const SizedBox(width: 10),
                      Semantics(
                        button: true,
                        label: 'Open account',
                        child: InkWell(
                          onTap: _openAccount,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              auth.user?.initials ?? 'S',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (products.isLoadingHome && !hasData)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LoadingView(),
                )
              else if (products.homeError != null && !hasData)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorStateView(
                    message: products.homeError!,
                    onRetry: () => products.loadHome(refresh: true),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curated for\neveryday living.',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 40, height: 1.06),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Text(
                            'A considered edit of audio, objects and everyday '
                            'essentials — chosen for how they live with you.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 12.5, height: 1.65),
                          ),
                        ),
                        const SizedBox(height: 22),
                        AppSearchField(
                          controller: _searchController,
                          hint: 'Search headphones, watches, bags…',
                          showClear: _searchText.isNotEmpty,
                          onChanged: (value) =>
                              setState(() => _searchText = value),
                          onSubmitted: (_) => _submitSearch(),
                          onClear: () {
                            _searchController.clear();
                            setState(() => _searchText = '');
                          },
                        ),
                        if (!products.isLiveBackend) ...[
                          const SizedBox(height: 14),
                          const DemoModeBanner(compact: true),
                        ],
                        const SizedBox(height: 28),
                        SectionHeader(
                          title: 'Shop by category',
                          actionLabel: 'View all',
                          onAction: () => _openListing(),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: products.categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final category = products.categories[index];
                        return CategoryTile(
                          category: category,
                          selected:
                              products.selectedCategoryId == category.id,
                          onTap: () => _openListing(categoryId: category.id),
                        );
                      },
                    ),
                  ),
                ),
                if (products.homeError != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: HomeErrorBanner(
                        message: products.homeError!,
                        onRetry: () => products.loadHome(refresh: true),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: PromoBanner(onTap: () => _openListing()),
                  ),
                ),
                if (products.featuredProducts.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                      child: SectionHeader(
                        title: 'Featured picks',
                        actionLabel: 'View all',
                        onAction: () => _openListing(),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 288,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                        itemCount: products.featuredProducts.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 14),
                        itemBuilder: (context, index) {
                          final product = products.featuredProducts[index];
                          return SizedBox(
                            width: 190,
                            child: ProductCard(
                              product: product,
                              onTap: () => _openProduct(product),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 14),
                    child: SectionHeader(
                      title: 'New arrivals',
                      actionLabel: 'Shop all',
                      onAction: () => _openListing(),
                    ),
                  ),
                ),
                if (products.homeProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: HomeEmptyState(onRetry: () => products.loadHome()),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: _gridDelegate(context),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = products.homeProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => _openProduct(product),
                          );
                        },
                        childCount: products.homeProducts.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 34, 24, 20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SHOPSPHERE  ·  BY SANKAR GROUP',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontSize: 8.5,
                                letterSpacing: 1.4,
                                color: AppColors.muted.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
