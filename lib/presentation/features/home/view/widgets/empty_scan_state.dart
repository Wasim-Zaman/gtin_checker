import 'package:flutter/material.dart';

class EmptyScanState extends StatelessWidget {
  const EmptyScanState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan a barcode to see results',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a barcode in the field above\nor use the scanner button',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
