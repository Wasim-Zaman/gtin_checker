import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shared_preferences_provider.dart';
import 'base_client.dart';

/// Provider for the BaseClient singleton instance
final baseClientProvider = Provider<BaseClient>((ref) {
  final client = BaseClient(timeout: const Duration(minutes: 1));

  // Get token from shared preferences and set it in the client
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final token = prefsService.getToken();
  if (token != null) {
    client.setAccessToken(token);
  }

  return client;
});

/// Provider that automatically disposes the BaseClient when the app is destroyed
final baseClientProviderAutoDispose = Provider.autoDispose<BaseClient>((ref) {
  final client = BaseClient(timeout: const Duration(minutes: 1));

  // Get token from shared preferences and set it in the client
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  final token = prefsService.getToken();
  if (token != null) {
    client.setAccessToken(token);
  }

  // Dispose the client when the provider is disposed
  ref.onDispose(() {
    client.dispose();
  });

  return client;
});
