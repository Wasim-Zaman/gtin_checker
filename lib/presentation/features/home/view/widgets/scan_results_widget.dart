import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../providers/barcode_providers.dart';
import 'result_card.dart';

class ScanResultsWidget extends StatelessWidget {
  final BarcodeResult result;
  final String Function(BarcodeType) getBarcodeTypeText;
  final IconData Function(BarcodeType) getBarcodeTypeIcon;

  const ScanResultsWidget({
    super.key,
    required this.result,
    required this.getBarcodeTypeText,
    required this.getBarcodeTypeIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withValues(alpha: 0.1),
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.analytics, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Scan Results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ResultCard(
            title: 'Scanned Value:',
            value: result.scannedValue,
            icon: Icons.qr_code,
          ),
          ResultCard(
            title: 'Barcode Type:',
            value: getBarcodeTypeText(result.type),
            icon: getBarcodeTypeIcon(result.type),
          ),
          if (result.gtin != null)
            ResultCard(
              title: 'GTIN:',
              value: result.gtin!,
              highlight: true,
              icon: Icons.tag,
            ),
          if (result.additionalData != null &&
              result.additionalData!.isNotEmpty)
            ...result.additionalData!.entries.map(
              (entry) => ResultCard(
                title: 'AI (${entry.key}):',
                value: entry.value.toString(),
                icon: Icons.description,
              ),
            ),
          if (result.gtin != null)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go('/product/${result.gtin}');
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('VIEW PRODUCT DETAILS'),
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
