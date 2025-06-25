import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_client.dart';

/// Provider for the BaseClient singleton instance
final baseClientProvider = Provider<BaseClient>((ref) {
  return BaseClient(timeout: const Duration(minutes: 1));
});

/// Provider that automatically disposes the BaseClient when the app is destroyed
final baseClientProviderAutoDispose = Provider.autoDispose<BaseClient>((ref) {
  final client = BaseClient(timeout: const Duration(minutes: 1));

  // Dispose the client when the provider is disposed
  ref.onDispose(() {
    client.dispose();
  });

  return client;
});
