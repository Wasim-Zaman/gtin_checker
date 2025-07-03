import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/base_client_provider.dart';
import '../../../../models/product.dart';
import '../models/product_submit.dart';
import '../../../../services/product_submit_service.dart';

final productSubmitServiceProvider = Provider<ProductSubmitService>((ref) {
  final baseClient = ref.watch(baseClientProvider(null));
  return ProductSubmitService(client: baseClient);
});

final productSubmitLoadingProvider = StateProvider<bool>((ref) => false);

final productSubmitProvider =
    FutureProvider.family<ProductSubmitResponse, ProductSubmitParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(productSubmitServiceProvider);
      return await service.submitProduct(
        product: params.product,
        scanningTime: params.scanningTime,
      );
    });

class ProductSubmitParams {
  final Products product;
  final DateTime scanningTime;

  ProductSubmitParams({required this.product, required this.scanningTime});
}

// Manual submission provider for button press
final submitProductManuallyProvider =
    StateNotifierProvider<
      ProductSubmitNotifier,
      AsyncValue<ProductSubmitResponse?>
    >((ref) {
      final service = ref.watch(productSubmitServiceProvider);
      return ProductSubmitNotifier(service);
    });

class ProductSubmitNotifier
    extends StateNotifier<AsyncValue<ProductSubmitResponse?>> {
  final ProductSubmitService _service;

  ProductSubmitNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> submitProduct(Products product, DateTime scanningTime) async {
    state = const AsyncValue.loading();

    try {
      final response = await _service.submitProduct(
        product: product,
        scanningTime: scanningTime,
      );
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
