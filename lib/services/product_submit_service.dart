import 'package:flutter/foundation.dart';

import '../core/network/api_urls.dart';
import '../core/network/base_client.dart';
import '../core/network/base_client_model.dart';
import '../models/product.dart';
import '../presentation/features/product_details/models/product_submit.dart';

class ProductSubmitService {
  final BaseClient _client;

  ProductSubmitService({required BaseClient client}) : _client = client;

  Future<ProductSubmitResponse> submitProduct({
    required Products product,
    required DateTime scanningTime,
  }) async {
    try {
      if (kDebugMode) {
        print('Submitting product for GTIN: ${product.barcode}');
      }

      final request = _createSubmitRequest(product, scanningTime);

      final response = await _client.post(
        ApiUrls.submitProduct,
        body: request.toJson(),
      );

      if (response.isSuccess) {
        final data = response.data;
        return ProductSubmitResponse.fromJson(data);
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

          default:
            errorMessage = 'Unknown error: ${response.errorMessage}';
            break;
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting product: $e');
      }
      throw Exception('Failed to submit product data: $e');
    }
  }

  ProductSubmitRequest _createSubmitRequest(
    Products product,
    DateTime scanningTime,
  ) {
    return ProductSubmitRequest(
      gtin: product.barcode ?? '',
      gpcCategoryCode: product.gpcCode,
      gpcCategoryName: product.gpcName ?? product.gpc,
      brandName: product.brandName,
      brandLanguage: product.prodLang ?? 'en',
      productDescription: product.detailsPage,
      productDescLanguage: product.prodLang ?? 'en',
      productImageUrl:
          product.productImageUrl ?? product.frontImage?.toString(),
      productImageLanguage: 'en',
      unitCode: product.unit,
      unitValue: product.size,
      productName: product.productnameenglish,
      companyName: product.companyName,
      moName: product.moName,
      licenceKey: product.licenceKey ?? product.memberID,
      licenceType: product.licenceType ?? product.gcpType,
      type: 'global',
      countryOfSaleName: product.countrySale,
      companyRegistrationDate: product.createdAt,
      gcpGLNID: product.gcpGLNID,
      contactWebsite: product.contactWebsite ?? product.productUrl,
      formattedAddress: product.formattedAddress,
      dateTimeScanned: scanningTime,
    );
  }
}
