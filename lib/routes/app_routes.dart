import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/account/account_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/products/product_details_screen.dart';
import '../screens/products/product_listing_screen.dart';
import '../screens/splash/splash_screen.dart';

class ProductListingArgs {
  const ProductListingArgs({this.categoryId, this.query});

  final String? categoryId;
  final String? query;
}

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String account = '/account';
  static const String products = '/products';
  static const String productDetails = '/product-details';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _page(const SplashScreen(), settings);
      case login:
        return _page(const LoginScreen(), settings);
      case signup:
        return _page(const SignupScreen(), settings);
      case home:
        return _page(const HomeScreen(), settings);
      case account:
        return _page(const AccountScreen(), settings);
      case products:
        final arguments = settings.arguments;
        final args = arguments is ProductListingArgs
            ? arguments
            : const ProductListingArgs();
        return _page(
          ProductListingScreen(
            initialCategoryId: args.categoryId,
            initialQuery: args.query,
          ),
          settings,
        );
      case productDetails:
        final arguments = settings.arguments;
        if (arguments is Product) {
          return _page(ProductDetailsScreen(product: arguments), settings);
        }
        return _page(const LoginScreen(), settings);
      default:
        return _page(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (_) => child,
      settings: settings,
    );
  }
}
