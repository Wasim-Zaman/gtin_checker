import 'package:flutter_riverpod/flutter_riverpod.dart';

// Auth state provider
final authStateProvider = StateProvider<bool>((ref) => false);

// Login loading state provider
final loginLoadingProvider = StateProvider<bool>((ref) => false);

// NFC loading state provider
final nfcLoadingProvider = StateProvider<bool>((ref) => false);
