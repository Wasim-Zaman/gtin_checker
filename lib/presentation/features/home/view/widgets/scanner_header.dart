import 'package:flutter/material.dart';

class ScannerHeader extends StatelessWidget {
  final Animation<double> scanAnimation;

  const ScannerHeader({super.key, required this.scanAnimation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                AnimatedBuilder(
                  animation: scanAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 26 + 28 * scanAnimation.value,
                      child: Container(
                        height: 2,
                        width: 50,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary.withValues(alpha: 0.8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.tertiary.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GTIN Verifier',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan or enter a barcode to verify',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
