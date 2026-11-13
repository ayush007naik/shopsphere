import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/models/app_user.dart';
import 'package:shopsphere/models/bag_item.dart';
import 'package:shopsphere/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses a Supabase row with a joined category', () {
      final product = Product.fromJson({
        'id': 'abc',
        'name': 'Aurora Headphones',
        'description': 'Great sound',
        'price': 149.5,
        'image_url': 'https://example.com/image.jpg',
        'category_id': 'cat-1',
        'categories': {'name': 'Audio'},
        'rating': 4.8,
        'stock': 12,
        'is_featured': true,
      });

      expect(product.id, 'abc');
      expect(product.name, 'Aurora Headphones');
      expect(product.price, 149.5);
      expect(product.categoryName, 'Audio');
      expect(product.isFeatured, isTrue);
      expect(product.inStock, isTrue);
    });

    test('falls back safely when optional fields are missing', () {
      final product = Product.fromJson({'id': 7, 'name': 'Lamp'});

      expect(product.id, '7');
      expect(product.description, '');
      expect(product.price, 0);
      expect(product.categoryName, 'ShopSphere');
      expect(product.rating, 0);
      expect(product.stock, 0);
      expect(product.inStock, isFalse);
    });

    test('round-trips through toJson for local persistence', () {
      final product = Product.fromJson({
        'id': 'p1',
        'name': 'Tote',
        'price': 89,
        'stock': 3,
        'categories': {'name': 'Bags'},
      });

      final restored = Product.fromJson(product.toJson());
      expect(restored.name, 'Tote');
      expect(restored.categoryName, 'Bags');
      expect(restored.price, 89);
      expect(restored.stock, 3);
    });
  });

  group('BagItem', () {
    test('calculates line totals and survives JSON', () {
      const product = Product(
        id: 'p1',
        name: 'Candle',
        description: 'Soy candle',
        price: 24,
        imageUrl: '',
        categoryId: 'c1',
        categoryName: 'Home & Living',
        rating: 4.8,
        stock: 10,
        isFeatured: false,
      );

      const item = BagItem(product: product, quantity: 3);
      expect(item.lineTotal, 72);

      final restored = BagItem.fromJson(item.toJson());
      expect(restored.quantity, 3);
      expect(restored.product.name, 'Candle');
      expect(restored.lineTotal, 72);
    });
  });

  group('AppUser', () {
    test('builds initials and first name', () {
      const user = AppUser(
        id: '1',
        email: 'ada@example.com',
        fullName: 'Ada Lovelace',
      );

      expect(user.firstName, 'Ada');
      expect(user.initials, 'AL');
    });

    test('handles single names and empty values', () {
      const user = AppUser(id: '1', email: 'x@y.com', fullName: 'Ada');
      expect(user.initials, 'A');

      const empty = AppUser(id: '2', email: '', fullName: '   ');
      expect(empty.firstName, 'Shopper');
      expect(empty.initials, 'S');
    });
  });
}
