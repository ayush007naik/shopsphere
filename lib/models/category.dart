/// A product category returned by the `categories` table.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final String slug;
  final String icon;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Uncategorised',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String? ?? 'category',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
