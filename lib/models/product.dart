/// A product row from Supabase, optionally joined with its category name.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.rating,
    required this.stock,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? categoryId;
  final String categoryName;
  final double rating;
  final int stock;
  final bool isFeatured;

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    final joinedCategory = json['categories'];
    final categoryName = joinedCategory is Map<String, dynamic>
        ? joinedCategory['name'] as String?
        : json['category_name'] as String?;

    return Product(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Untitled product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: categoryName ?? 'ShopSphere',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'rating': rating,
      'stock': stock,
      'is_featured': isFeatured,
    };
  }
}
