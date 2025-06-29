import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gtin_checker/core/network/base_client_provider.dart';
import 'package:gtin_checker/models/auth_models.dart';
import 'package:gtin_checker/services/user_service.dart';

final userServiceProvider = Provider<UserApiService>((ref) {
  final baseClient = ref.watch(baseClientProvider);
  return UserApiService(client: baseClient);
});

class UserNotifier extends Notifier<User?> {
  @override
  User? build() {
    return null;
  }

  void getUser() async {
    ref.read(userServiceProvider).getUserByToken().then((user) {
      state = user;
    });
  }
}
