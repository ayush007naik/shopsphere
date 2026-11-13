import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;

import '../core/services/local_storage_service.dart';
import '../core/services/product_repository.dart';
import '../core/services/supabase_service.dart';
import '../core/utils/error_mapper.dart';
import '../models/category.dart';
import '../models/product.dart';

/// Owns catalogue data for both the home dashboard and the product listing.
class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository, this._storage)
    : _recentSearches = _storage.searchHistory;

  final ProductRepository _repository;
  final LocalStorageService _storage;

  List<Category> _categories = const [];
  List<Product> _featuredProducts = const [];
  List<Product> _homeProducts = const [];
  List<Product> _products = const [];
  List<String> _recentSearches;

  bool _isLoadingHome = false;
  bool _isLoadingProducts = false;
  String? _homeError;
  String? _productsError;
  String? _selectedCategoryId;
  String _query = '';
  int _listingRequestId = 0;
  Timer? _searchDebounce;

  List<Category> get categories => List.unmodifiable(_categories);
  List<Product> get featuredProducts => List.unmodifiable(_featuredProducts);
  List<Product> get homeProducts => List.unmodifiable(_homeProducts);
  List<Product> get products => List.unmodifiable(_products);
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  bool get isLoadingHome => _isLoadingHome;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get homeError => _homeError;
  String? get productsError => _productsError;
  String? get selectedCategoryId => _selectedCategoryId;
  String get query => _query;
  bool get isLiveBackend => SupabaseService.isInitialized;
  bool get hasActiveFilters =>
      _selectedCategoryId != null || _query.trim().isNotEmpty;

  Category? get selectedCategory {
    if (_selectedCategoryId == null) return null;
    for (final category in _categories) {
      if (category.id == _selectedCategoryId) return category;
    }
    return null;
  }

  /// Loads categories, featured picks and the latest arrivals for the home
  /// dashboard. The three requests run in parallel.
  Future<void> loadHome({bool refresh = false}) async {
    if (_isLoadingHome) return;

    _isLoadingHome = true;
    _homeError = null;
    notifyListeners();

    try {
      final (categories, featured, latest) = await (
        _repository.fetchCategories(),
        _repository.fetchProducts(featuredOnly: true, limit: 8),
        _repository.fetchProducts(limit: 6),
      ).wait;

      _categories = categories;
      _featuredProducts = featured;
      _homeProducts = latest;
      _recentSearches = _storage.searchHistory;
    } catch (error) {
      _homeError = friendlyError(error);
      if (refresh) {
        _categories = const [];
        _featuredProducts = const [];
        _homeProducts = const [];
      }
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  /// Entry point for the listing screen. Resets filters unless instructed
  /// otherwise so navigation from a category always shows that category.
  Future<void> openListing({
    String? categoryId,
    String? query,
    bool resetFilters = true,
  }) async {
    _searchDebounce?.cancel();
    if (resetFilters) {
      _selectedCategoryId = categoryId;
      _query = query?.trim() ?? '';
      _products = const [];
    } else {
      if (categoryId != null) _selectedCategoryId = categoryId;
      if (query != null) _query = query.trim();
    }
    await fetchListing();
  }

  Future<void> selectCategory(String? categoryId) async {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    notifyListeners();
    await fetchListing();
  }

  /// Debounces keystrokes so a request is only made when typing pauses.
  void onSearchChanged(String value) {
    _query = value;
    notifyListeners();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      fetchListing();
    });
  }

  Future<void> submitSearch(String value) async {
    _searchDebounce?.cancel();
    _query = value.trim();
    await _storage.addSearchQuery(_query);
    _recentSearches = _storage.searchHistory;
    await fetchListing();
  }

  Future<void> clearSearchHistory() async {
    await _storage.clearSearchHistory();
    _recentSearches = const [];
    notifyListeners();
  }

  Future<void> resetFilters() async {
    _searchDebounce?.cancel();
    _selectedCategoryId = null;
    _query = '';
    notifyListeners();
    await fetchListing();
  }

  Future<void> retryListing() => fetchListing();

  Future<void> fetchListing() async {
    final requestId = ++_listingRequestId;
    _isLoadingProducts = true;
    _productsError = null;
    notifyListeners();

    try {
      final results = await _repository.fetchProducts(
        categoryId: _selectedCategoryId,
        query: _query,
      );
      if (requestId != _listingRequestId) return;
      _products = results;
    } catch (error) {
      if (requestId != _listingRequestId) return;
      _productsError = friendlyError(error);
      _products = const [];
    } finally {
      if (requestId == _listingRequestId) {
        _isLoadingProducts = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
