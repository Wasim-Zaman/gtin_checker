import 'package:flutter/foundation.dart';
import 'package:gtin_checker/core/network/base_client.dart';
import 'package:gtin_checker/core/network/base_client_model.dart';
import 'package:gtin_checker/models/auth_models.dart';

class UserApiService {
  final BaseClient _client;

  UserApiService({required BaseClient client}) : _client = client;

  Future<User?> getUserByToken() async {
    final response = await _client.get('/users/profile');

    if (response.isSuccess) {
      final data = response.data;
      return User.fromJson(data);
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
        print('User API Error: $errorMessage');
      }

      throw Exception(errorMessage);
    }
  }
}
