import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gtin_checker/providers/shared_preferences_provider.dart';

import '../presentation/features/auth/view/login_screen.dart';
import '../presentation/features/home/view/barcode_verifier_screen.dart';
import '../presentation/features/product_details/view/product_details_screen.dart';
import '../presentation/features/report/view/create_report_screen.dart';
import '../presentation/features/test/view/barcode_test_screen.dart';

final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      // check if the user is logged in, get the shared preferences provider
      final sharedPreferences = ref.read(sharedPreferencesServiceProvider);
      final isLoggedIn = sharedPreferences.isLoggedIn();

      // check if user is not logged in, then he cannot go to any route without login
      print("Is logged in: $isLoggedIn");
      if (!isLoggedIn && state.matchedLocation != "/login") {
        return "/login";
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => const BarcodeVerifierScreen(),
      ),
      GoRoute(
        path: '/test',
        builder: (context, state) => const BarcodeTestScreen(),
      ),
      GoRoute(
        path: '/product/:barcode',
        builder: (context, state) {
          final barcode = state.pathParameters['barcode'] ?? '';
          return ProductDetailsScreen(barcode: barcode);
        },
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const CreateReportScreen(),
      ),
    ],
  );
});
