import 'package:flutter/foundation.dart';

import '../core/network/api_urls.dart';
import '../core/network/base_client.dart';
import '../core/network/base_client_model.dart';
import '../models/product.dart';

class ProductApiService {
  final BaseClient _client;

  ProductApiService({required BaseClient client}) : _client = client;

  Future<ProductResponse> getProductByBarcode(String barcode) async {
    try {
      // Use the base client to make the request
      final response = await _client.get(
        ApiUrls.productDetails,
        queryParams: {'barcode': barcode},
      );

      if (response.isSuccess) {
        final data = response.data;

        // Return ProductResponse with the new API format
        return ProductResponse.fromJson(data);
      } else {
        // Handle different error types from BaseClient
        String errorMessage;
        switch (response.status) {
          case BaseClientStatus.networkError:
            errorMessage = 'Network error: ${response.errorMessage}';
            break;
          case BaseClientStatus.timeoutError:
            errorMessage = 'Request timeout: ${response.errorMessage}';
            break;
          case BaseClientStatus.formatError:
            errorMessage = 'Data format error: ${response.errorMessage}';
            break;
          case BaseClientStatus.failure:
            errorMessage = 'API error: ${response.errorMessage}';
            break;
          case BaseClientStatus.unexpectedError:
            errorMessage = 'Unexpected error: ${response.errorMessage}';
            break;
          default:
            errorMessage = 'Unknown error occurred';
        }

        if (kDebugMode) {
          print('Product API Error: $errorMessage');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching product: $e');
      }
      rethrow;
    }
  }
}
