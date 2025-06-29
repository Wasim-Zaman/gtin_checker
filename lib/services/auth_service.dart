import 'package:flutter/foundation.dart';
import 'package:gtin_checker/core/network/api_urls.dart';

import '../core/network/base_client.dart';
import '../core/network/base_client_model.dart';
import '../models/auth_models.dart';

class AuthService {
  final BaseClient _client;

  AuthService({required BaseClient client}) : _client = client;

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        ApiUrls.login,
        body: {'email': email, 'password': password},
      );

      if (response.isSuccess) {
        final data = response.data;
        return LoginResponse.fromJson(data);
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
            errorMessage = 'Login failed: ${response.errorMessage}';
            break;
          case BaseClientStatus.unexpectedError:
            errorMessage = 'Unexpected error: ${response.errorMessage}';
            break;
          default:
            errorMessage = 'Unknown error occurred';
        }

        if (kDebugMode) {
          print('Auth API Error: $errorMessage');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      rethrow;
    }
  }

  Future<LoginResponse> nfcLogin(String nfcCardData) async {
    try {
      if (nfcCardData.isEmpty) {
        throw Exception('No NFC card data provided');
      }

      if (kDebugMode) {
        print('NFC Login with card data: $nfcCardData');
      }

      // Make the actual API call to your NFC login endpoint
      final response = await _client.post(
        ApiUrls.nfcLogin,
        body: {'nfcNumber': nfcCardData},
      );

      if (response.isSuccess) {
        final data = response.data;
        return LoginResponse.fromJson(data);
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
            errorMessage = 'NFC Login failed: ${response.errorMessage}';
            break;
          case BaseClientStatus.unexpectedError:
            errorMessage = 'Unexpected error: ${response.errorMessage}';
            break;
          default:
            errorMessage = 'Unknown error occurred';
        }

        if (kDebugMode) {
          print('NFC Auth API Error: $errorMessage');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during NFC login: $e');
      }
      rethrow;
    }
  }
}
