import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/theme/app_theme.dart';
import 'package:shopsphere/models/product.dart';
import 'package:shopsphere/widgets/product_card.dart';

void main() {
  const product = Product(
    id: 'p1',
    name: 'Aurora Wireless Headphones',
    description: 'Adaptive noise cancelling headphones.',
    price: 149,
    imageUrl: '',
    categoryId: 'c1',
    categoryName: 'Audio',
    rating: 4.8,
    stock: 10,
    isFeatured: true,
  );

  testWidgets('renders product information and handles taps', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 330,
              child: ProductCard(
                product: product,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Aurora Wireless Headphones'), findsOneWidget);
    expect(find.text(r'$149.00'), findsOneWidget);
    expect(find.text('AUDIO'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);

    await tester.tap(find.text('Aurora Wireless Headphones'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('shows a sold out badge when stock is zero', (tester) async {
    const soldOut = Product(
      id: 'p2',
      name: 'Archive Tote',
      description: '',
      price: 89,
      imageUrl: '',
      categoryId: 'c2',
      categoryName: 'Bags',
      rating: 4.5,
      stock: 0,
      isFeatured: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 330,
              child: ProductCard(product: soldOut, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SOLD OUT'), findsOneWidget);
  });
}
