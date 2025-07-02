import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/base_client_provider.dart';
import '../models/report.dart';
import '../services/report_service.dart';

final reportServiceProvider = Provider<ReportService>((ref) {
  final baseClient = ref.watch(
    baseClientProvider(null),
  ); // Use file upload client
  return ReportService(client: baseClient);
});

class ReportNotifier extends AsyncNotifier<Report?> {
  @override
  Future<Report?> build() async {
    return null;
  }

  Future<void> createReport({
    required String gtin,
    required DateTime dateTimeScanned,
    required List<File> images,
  }) async {
    state = const AsyncValue.loading();

    try {
      final reportService = ref.read(reportServiceProvider);
      final response = await reportService.createReport(
        gtin: gtin,
        dateTimeScanned: dateTimeScanned,
        images: images,
      );

      state = AsyncValue.data(response.data);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final reportProvider = AsyncNotifierProvider<ReportNotifier, Report?>(() {
  return ReportNotifier();
});

// State providers for the report form
final reportGtinProvider = StateProvider<String>((ref) => '');
final reportImagesProvider = StateProvider<List<File>>((ref) => []);
final reportDateTimeProvider = StateProvider<DateTime>((ref) => DateTime.now());
