import '../../models/category.dart';
import '../../models/product.dart';

/// Sample catalogue used when Supabase credentials have not been supplied.
///
/// The IDs and records mirror `supabase_setup.sql`, so switching from the
/// offline demo to a live project does not change the UI contract.
class DemoData {
  const DemoData._();

  static const List<Category> categories = [
    Category(
      id: '11111111-1111-4111-8111-111111111101',
      name: 'Audio',
      slug: 'audio',
      icon: 'headphones',
      sortOrder: 1,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111102',
      name: 'Watches',
      slug: 'watches',
      icon: 'watch',
      sortOrder: 2,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111103',
      name: 'Bags',
      slug: 'bags',
      icon: 'bag',
      sortOrder: 3,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111104',
      name: 'Home & Living',
      slug: 'home-living',
      icon: 'home',
      sortOrder: 4,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111105',
      name: 'Footwear',
      slug: 'footwear',
      icon: 'footwear',
      sortOrder: 5,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111106',
      name: 'Eyewear',
      slug: 'eyewear',
      icon: 'eyewear',
      sortOrder: 6,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111107',
      name: 'Skincare',
      slug: 'skincare',
      icon: 'skincare',
      sortOrder: 7,
    ),
    Category(
      id: '11111111-1111-4111-8111-111111111108',
      name: 'Tech',
      slug: 'tech',
      icon: 'tech',
      sortOrder: 8,
    ),
  ];

  static const List<Product> products = [
    Product(
      id: '22222222-2222-4222-8222-222222222201',
      name: 'Aurora Wireless Headphones',
      description:
          'Immersive over-ear headphones with adaptive noise cancelling and a '
          '40-hour battery. Memory-foam cushions keep long listening sessions '
          'comfortable, while the fold-flat design travels easily.',
      price: 149,
      imageUrl:
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111101',
      categoryName: 'Audio',
      rating: 4.8,
      stock: 24,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222202',
      name: 'Pulse Mini Speaker',
      description:
          'A pocket-sized speaker with a surprisingly full sound. Splash '
          'resistant, USB-C rechargeable, and ready for twelve hours of play.',
      price: 79,
      imageUrl:
          'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111101',
      categoryName: 'Audio',
      rating: 4.5,
      stock: 41,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222203',
      name: 'Heritage Leather Watch',
      description:
          'A quietly confident timepiece with a brushed stainless case and a '
          'vegetable-tanned leather strap. Japanese quartz movement keeps it '
          'precise; the slim profile keeps it versatile.',
      price: 219,
      imageUrl:
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111102',
      categoryName: 'Watches',
      rating: 4.7,
      stock: 12,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222204',
      name: 'Meridian Smartwatch',
      description:
          'Health tracking, notifications and a bright always-on display in a '
          'clean, minimal case. Up to seven days of battery on a single charge.',
      price: 199,
      imageUrl:
          'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111102',
      categoryName: 'Watches',
      rating: 4.6,
      stock: 18,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222205',
      name: 'Voyager Canvas Backpack',
      description:
          'A hard-wearing canvas backpack with a padded laptop sleeve and '
          'thoughtful internal pockets. Designed for commutes, weekends and '
          'everything in between.',
      price: 89,
      imageUrl:
          'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111103',
      categoryName: 'Bags',
      rating: 4.6,
      stock: 30,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222206',
      name: 'Atelier Leather Tote',
      description:
          'An everyday tote cut from full-grain leather that softens with use. '
          'Roomy enough for a 14-inch laptop, finished with hand-stitched '
          'handles.',
      price: 129,
      imageUrl:
          'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111103',
      categoryName: 'Bags',
      rating: 4.9,
      stock: 9,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222207',
      name: 'Halo Ceramic Lamp',
      description:
          'A hand-glazed ceramic table lamp that casts a warm, diffused glow. '
          'The soft neutral finish sits comfortably in bedrooms, reading nooks '
          'and living rooms.',
      price: 69,
      imageUrl:
          'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111104',
      categoryName: 'Home & Living',
      rating: 4.4,
      stock: 22,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222208',
      name: 'Solstice Soy Candle',
      description:
          'Hand-poured soy wax with notes of cedar, amber and bergamot. Burns '
          'cleanly for up to 45 hours in a reusable stoneware vessel.',
      price: 24,
      imageUrl:
          'https://images.unsplash.com/photo-1602874801007-bd458bb1b8b6?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111104',
      categoryName: 'Home & Living',
      rating: 4.8,
      stock: 65,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222209',
      name: 'Terra Runner Sneakers',
      description:
          'Lightweight everyday runners with a breathable knit upper and a '
          'responsive foam midsole. Built for city miles and easy weekends.',
      price: 119,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111105',
      categoryName: 'Footwear',
      rating: 4.7,
      stock: 27,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222210',
      name: 'Court Classic Trainers',
      description:
          'A clean leather court shoe that works with denim, tailoring and '
          'everything in between. Cushioned insole and a durable rubber sole.',
      price: 99,
      imageUrl:
          'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111105',
      categoryName: 'Footwear',
      rating: 4.5,
      stock: 34,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222211',
      name: 'Horizon Sunglasses',
      description:
          'Classic acetate frames with polarised lenses and full UV400 '
          'protection. A timeless silhouette with a comfortable keyhole bridge.',
      price: 79,
      imageUrl:
          'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111106',
      categoryName: 'Eyewear',
      rating: 4.6,
      stock: 19,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222212',
      name: 'Studio Round Frames',
      description:
          'Fine metal frames with a rounded shape and lightweight feel. Comes '
          'with clear lenses ready for your prescription.',
      price: 59,
      imageUrl:
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111106',
      categoryName: 'Eyewear',
      rating: 4.3,
      stock: 14,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222213',
      name: 'Botanic Glow Serum',
      description:
          'A lightweight vitamin C serum that brightens and evens tone without '
          'stickiness. Formulated with botanical antioxidants for daily use.',
      price: 39,
      imageUrl:
          'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111107',
      categoryName: 'Skincare',
      rating: 4.8,
      stock: 52,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222214',
      name: 'Daily Ritual Moisturiser',
      description:
          'A ceramide-rich daily moisturiser that strengthens the skin barrier '
          'and layers well under sunscreen. Fragrance free and non-greasy.',
      price: 29,
      imageUrl:
          'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111107',
      categoryName: 'Skincare',
      rating: 4.7,
      stock: 70,
      isFeatured: false,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222215',
      name: 'Tactile Mechanical Keyboard',
      description:
          'A compact 75% mechanical keyboard with hot-swappable switches and a '
          'solid aluminium frame. Bluetooth and USB-C connectivity for a tidy '
          'desk setup.',
      price: 139,
      imageUrl:
          'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111108',
      categoryName: 'Tech',
      rating: 4.9,
      stock: 16,
      isFeatured: true,
    ),
    Product(
      id: '22222222-2222-4222-8222-222222222216',
      name: 'Frame Compact Camera',
      description:
          'A pocketable mirrorless camera with a 24MP sensor and a bright prime '
          'lens. Film-inspired colour profiles make everyday moments feel '
          'considered.',
      price: 349,
      imageUrl:
          'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=900&q=80',
      categoryId: '11111111-1111-4111-8111-111111111108',
      categoryName: 'Tech',
      rating: 4.7,
      stock: 7,
      isFeatured: false,
    ),
  ];
}
