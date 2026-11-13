import 'product.dart';

/// A product plus quantity, persisted locally in SharedPreferences.
class BagItem {
  const BagItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  BagItem copyWith({int? quantity}) {
    return BagItem(product: product, quantity: quantity ?? this.quantity);
  }

  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  factory BagItem.fromJson(Map<String, dynamic> json) {
    return BagItem(
      product: Product.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
