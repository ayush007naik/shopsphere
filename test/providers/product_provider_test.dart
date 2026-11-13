import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/services/demo_data.dart';
import 'package:shopsphere/core/services/local_storage_service.dart';
import 'package:shopsphere/core/services/product_repository.dart';
import 'package:shopsphere/models/category.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/providers/product_provider.dart';

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });

  test('loadHome loads categories, featured and latest products', () async {
    final provider = ProductProvider(
      const DemoProductRepository(latency: Duration.zero),
      storage,
    );
    addTearDown(provider.dispose);

    await provider.loadHome();

    expect(provider.isLoadingHome, isFalse);
    expect(provider.homeError, isNull);
    expect(provider.categories, hasLength(8));
    expect(provider.featuredProducts, isNotEmpty);
    expect(provider.homeProducts, hasLength(6));
  });

  test('selectCategory filters the listing', () async {
    final provider = ProductProvider(
      const DemoProductRepository(latency: Duration.zero),
      storage,
    );
    addTearDown(provider.dispose);

    await provider.loadHome();
    final audio = provider.categories.first;
    await provider.selectCategory(audio.id);

    expect(provider.selectedCategoryId, audio.id);
    expect(provider.products, isNotEmpty);
    expect(
      provider.products.every((product) => product.categoryId == audio.id),
      isTrue,
    );
  });

  test('submitSearch filters products and persists search history', () async {
    final provider = ProductProvider(
      const DemoProductRepository(latency: Duration.zero),
      storage,
    );
    addTearDown(provider.dispose);

    await provider.openListing();
    await provider.submitSearch('Aurora');

    expect(provider.products, hasLength(1));
    expect(provider.products.single.name, contains('Aurora'));
    expect(provider.recentSearches, contains('Aurora'));
    expect(storage.searchHistory, contains('Aurora'));
  });

  test('resetFilters clears category and query filters', () async {
    final provider = ProductProvider(
      const DemoProductRepository(latency: Duration.zero),
      storage,
    );
    addTearDown(provider.dispose);

    await provider.loadHome();
    await provider.openListing(
      categoryId: provider.categories.first.id,
      query: 'Aurora',
    );
    expect(provider.hasActiveFilters, isTrue);

    await provider.resetFilters();

    expect(provider.selectedCategoryId, isNull);
    expect(provider.query, isEmpty);
    expect(provider.hasActiveFilters, isFalse);
    expect(provider.products, hasLength(DemoData.products.length));
  });

  test('surfaces repository failures as error states', () async {
    final provider = ProductProvider(_FailingRepository(), storage);
    addTearDown(provider.dispose);

    await provider.loadHome();
    expect(provider.homeError, isNotNull);
    expect(provider.categories, isEmpty);

    await provider.openListing();
    expect(provider.productsError, isNotNull);
    expect(provider.products, isEmpty);
  });
}

class _FailingRepository implements ProductRepository {
  @override
  Future<List<Category>> fetchCategories() async {
    throw Exception('network unavailable');
  }

  @override
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String query = '',
    bool featuredOnly = false,
    int? limit,
  }) async {
    throw Exception('network unavailable');
  }
}
