import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/base_client_provider.dart';
import '../../../../models/auth_models.dart';
import '../../../../providers/shared_preferences_provider.dart';
import '../../../../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final baseClient = ref.watch(baseClientProvider);
  return AuthService(client: baseClient);
});

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);

      // Save token and user data to shared preferences
      final prefsService = ref.read(sharedPreferencesServiceProvider);
      await prefsService.saveToken(response.data.token);
      await prefsService.saveUser(response.data.user);
      await prefsService.setLoggedIn(true);

      // Update the BaseClient with the new token
      final baseClient = ref.read(baseClientProvider);
      baseClient.setAccessToken(response.data.token);

      state = AsyncValue.data(response.data.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> nfcLogin() async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      await authService.nfcLogin();

      // TODO: Handle NFC login response when implemented
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> logout() async {
    // Clear stored data
    final prefsService = ref.read(sharedPreferencesServiceProvider);
    await prefsService.clearAuthData();

    // Clear token from BaseClient
    final baseClient = ref.read(baseClientProvider);
    baseClient.setAccessToken(null);

    state = const AsyncValue.data(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  () => AuthNotifier(),
);

// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
