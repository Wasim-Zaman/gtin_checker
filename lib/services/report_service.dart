import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/network/api_urls.dart';
import '../core/network/base_client.dart';
import '../core/network/base_client_model.dart';
import '../models/report.dart';

class ReportService {
  final BaseClient _client;

  ReportService({required BaseClient client}) : _client = client;

  Future<ReportResponse> createReport({
    required String gtin,
    required DateTime dateTimeScanned,
    required List<File> images,
  }) async {
    try {
      if (kDebugMode) {
        print('Creating report for GTIN: $gtin with ${images.length} images');
      }

      // Prepare form fields
      final formFields = <String, String>{
        'gtin': gtin,
        'dateTimeScanned': dateTimeScanned.toIso8601String(),
      };

      // Prepare multiple files with the same field name "images"
      final multipleFiles = <String, List<File>>{'images': images};

      final response = await _client.postFormDataWithMultipleFiles(
        ApiUrls.createReport,
        formFields: formFields,
        multipleFiles: multipleFiles,
        bearerToken: _client.accessToken,
      );

      if (response.isSuccess) {
        final data = response.data;
        return ReportResponse.fromJson(data);
      } else {
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
          print('Report creation error: $errorMessage');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating report: $e');
      }
      rethrow;
    }
  }
}
