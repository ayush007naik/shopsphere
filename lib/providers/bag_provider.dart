import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/services/local_storage_service.dart';
import '../models/bag_item.dart';
import '../models/product.dart';

/// Small local shopping bag. Quantities are persisted in SharedPreferences so
/// the state survives app restarts. No payment or checkout flow is included.
class BagProvider extends ChangeNotifier {
  BagProvider(this._storage) : _items = _storage.loadBag();

  final LocalStorageService _storage;
  List<BagItem> _items;

  List<BagItem> get items => List.unmodifiable(_items);

  int get itemCount =>
      _items.fold(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold(0, (total, item) => total + item.lineTotal);

  bool get isEmpty => _items.isEmpty;

  int quantityFor(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  void add(Product product, {int quantity = 1}) {
    final maxQuantity = product.stock > 0 ? product.stock : 99;
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index == -1) {
      final initial = quantity.clamp(1, maxQuantity);
      _items = [..._items, BagItem(product: product, quantity: initial)];
    } else {
      final existing = _items[index];
      final updated = (existing.quantity + quantity).clamp(1, maxQuantity);
      _items = [..._items]..[index] = existing.copyWith(quantity: updated);
    }
    _commit();
  }

  void setQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (quantity <= 0) {
      remove(productId);
      return;
    }

    final existing = _items[index];
    final maxQuantity =
        existing.product.stock > 0 ? existing.product.stock : 99;
    _items = [..._items]
      ..[index] = existing.copyWith(
        quantity: quantity.clamp(1, maxQuantity),
      );
    _commit();
  }

  void remove(String productId) {
    _items = _items
        .where((item) => item.product.id != productId)
        .toList(growable: false);
    _commit();
  }

  void clear() {
    _items = const [];
    _commit();
  }

  void _commit() {
    unawaited(_storage.saveBag(_items));
    notifyListeners();
  }
}
