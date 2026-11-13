import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/category.dart';
import '../../models/product.dart';
import 'demo_data.dart';

abstract class ProductRepository {
  Future<List<Category>> fetchCategories();

  Future<List<Product>> fetchProducts({
    String? categoryId,
    String query = '',
    bool featuredOnly = false,
    int? limit,
  });
}

/// Live catalogue backed by the Supabase PostgreSQL database.
class SupabaseProductRepository implements ProductRepository {
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<List<Category>> fetchCategories() async {
    final rows = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);

    return rows
        .map((row) => Category.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  @override
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String query = '',
    bool featuredOnly = false,
    int? limit,
  }) async {
    var request = _client
        .from('products')
        .select('*, categories(name)');

    if (categoryId != null && categoryId.isNotEmpty) {
      request = request.eq('category_id', categoryId);
    }
    if (featuredOnly) {
      request = request.eq('is_featured', true);
    }

    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      request = request.ilike('name', '%$trimmed%');
    }

    var ordered = request.order('created_at', ascending: false);

    if (limit != null) {
      ordered = ordered.limit(limit);
    }

    final rows = await ordered;
    return rows
        .map((row) => Product.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}

/// Offline catalogue with the same filtering semantics as the live repository.
class DemoProductRepository implements ProductRepository {
  const DemoProductRepository({
    this.latency = const Duration(milliseconds: 600),
  });

  final Duration latency;

  @override
  Future<List<Category>> fetchCategories() async {
    await Future<void>.delayed(latency);
    return DemoData.categories;
  }

  @override
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String query = '',
    bool featuredOnly = false,
    int? limit,
  }) async {
    await Future<void>.delayed(latency);

    final trimmed = query.trim().toLowerCase();
    var results = DemoData.products.where((product) {
      final matchesCategory =
          categoryId == null || product.categoryId == categoryId;
      final matchesQuery =
          trimmed.isEmpty || product.name.toLowerCase().contains(trimmed);
      final matchesFeatured = !featuredOnly || product.isFeatured;
      return matchesCategory && matchesQuery && matchesFeatured;
    }).toList();

    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }
    return results;
  }
}
