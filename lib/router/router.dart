import 'package:go_router/go_router.dart';

import '../presentation/features/test/view/barcode_test_screen.dart';
import '../presentation/features/home/view/barcode_verifier_screen.dart';
import '../presentation/features/product_details/view/product_details_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
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
    // Add more routes here when needed for GS1 product information
  ],
);
