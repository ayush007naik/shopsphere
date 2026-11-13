import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/services/demo_data.dart';
import 'package:shopsphere/core/services/product_repository.dart';

void main() {
  const repository = DemoProductRepository(latency: Duration.zero);

  test('fetchCategories returns the seeded catalogue in order', () async {
    final categories = await repository.fetchCategories();
    expect(categories, hasLength(8));
    expect(categories.first.name, 'Audio');
    expect(categories.last.name, 'Tech');
  });

  test('fetchProducts returns every seeded product by default', () async {
    final products = await repository.fetchProducts();
    expect(products, hasLength(DemoData.products.length));
  });

  test('filters by category', () async {
    final audioId = DemoData.categories.first.id;
    final products = await repository.fetchProducts(categoryId: audioId);

    expect(products, isNotEmpty);
    expect(products.every((product) => product.categoryId == audioId), isTrue);
  });

  test('searches by name, case-insensitively', () async {
    final products = await repository.fetchProducts(query: 'AURORA');
    expect(products, hasLength(1));
    expect(products.single.name, contains('Aurora'));
  });

  test('returns featured products only when requested', () async {
    final products = await repository.fetchProducts(featuredOnly: true);
    expect(products, isNotEmpty);
    expect(products.every((product) => product.isFeatured), isTrue);
  });

  test('respects the limit parameter', () async {
    final products = await repository.fetchProducts(limit: 3);
    expect(products, hasLength(3));
  });

  test('returns an empty list when nothing matches', () async {
    final products = await repository.fetchProducts(query: 'zzzzz');
    expect(products, isEmpty);
  });
}
