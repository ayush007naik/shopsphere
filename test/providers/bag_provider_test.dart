import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/services/demo_data.dart';
import 'package:shopsphere/core/services/local_storage_service.dart';
import 'package:shopsphere/providers/bag_provider.dart';

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });

  test('adds products, merges quantities and calculates subtotal', () async {
    final bag = BagProvider(storage);
    final product = DemoData.products.first;

    bag.add(product, quantity: 2);
    bag.add(product, quantity: 1);

    expect(bag.itemCount, 3);
    expect(bag.items, hasLength(1));
    expect(bag.subtotal, closeTo(product.price * 3, 0.001));
  });

  test('updates, removes and clears quantities', () async {
    final bag = BagProvider(storage);
    final product = DemoData.products.first;

    bag.add(product);
    bag.setQuantity(product.id, 4);
    expect(bag.quantityFor(product.id), 4);

    bag.setQuantity(product.id, 0);
    expect(bag.isEmpty, isTrue);

    bag.add(product);
    bag.clear();
    expect(bag.isEmpty, isTrue);
    expect(bag.itemCount, 0);
  });

  test('restores the bag from SharedPreferences', () async {
    final bag = BagProvider(storage);
    final product = DemoData.products[1];
    bag.add(product, quantity: 2);
    await Future<void>.delayed(Duration.zero);

    final restored = BagProvider(storage);
    expect(restored.itemCount, 2);
    expect(restored.items.single.product.id, product.id);
  });

  test('clamps quantity to the available stock', () async {
    final bag = BagProvider(storage);
    final product = DemoData.products.firstWhere((item) => item.stock > 0);

    bag.add(product, quantity: product.stock + 20);

    expect(bag.quantityFor(product.id), product.stock);
  });
}
