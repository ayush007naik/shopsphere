import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/services/auth_repository.dart';
import 'core/services/demo_auth_repository.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/product_repository.dart';
import 'core/services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/bag_provider.dart';
import 'providers/product_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  final preferences = await SharedPreferences.getInstance();
  final storage = LocalStorageService(preferences);
  final isLive = SupabaseService.isInitialized;

  // Live Supabase repositories are used whenever credentials were supplied.
  // Otherwise the app falls back to an explicitly labelled local demo so the
  // assignment can still be launched and demonstrated.
  final AuthRepository authRepository = isLive
      ? SupabaseAuthRepository()
      : DemoAuthRepository(preferences);
  final ProductRepository productRepository = isLive
      ? SupabaseProductRepository()
      : const DemoProductRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository, storage),
        ),
        ChangeNotifierProvider(create: (_) => BagProvider(storage)),
      ],
      child: const ShopSphereApp(),
    ),
  );
}
