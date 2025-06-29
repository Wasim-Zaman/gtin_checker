import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/nfc_scan_providers.dart';

class NfcScanBottomSheet extends ConsumerStatefulWidget {
  final Function(String) onNfcScanned;
  final VoidCallback onCancel;

  const NfcScanBottomSheet({
    super.key,
    required this.onNfcScanned,
    required this.onCancel,
  });

  @override
  ConsumerState<NfcScanBottomSheet> createState() => _NfcScanBottomSheetState();
}

class _NfcScanBottomSheetState extends ConsumerState<NfcScanBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Start NFC scan automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nfcScanProvider.notifier).startNfcScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final nfcState = ref.watch(nfcScanProvider);

    // Listen to state changes for callbacks
    ref.listen<NfcScanState>(nfcScanProvider, (previous, current) {
      if (current.status == NfcScanStatus.success && current.cardData != null) {
        widget.onNfcScanned(current.cardData!);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24.0,
          16.0,
          24.0,
          MediaQuery.of(context).padding.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern handle bar
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 28),

            // Enhanced title with subtitle
            Column(
              children: [
                Text(
                  'NFC Authentication',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hold your NFC card near the device',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Enhanced NFC container without animations
            _buildEnhancedNfcContainer(nfcState, colorScheme),

            const SizedBox(height: 32),

            // Enhanced status indicator
            _buildStatusIndicator(nfcState, colorScheme, textTheme),

            const SizedBox(height: 32),

            // Modern action buttons
            _buildModernActionButtons(nfcState, colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedNfcContainer(
    NfcScanState nfcState,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: _getBackgroundColor(nfcState.status, colorScheme),
        shape: BoxShape.circle,
        border: Border.all(
          color: _getBorderColor(nfcState.status, colorScheme),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor(
              nfcState.status,
              colorScheme,
            ).withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: _buildNfcIcon(nfcState.status),
    );
  }

  Widget _buildNfcIcon(NfcScanStatus status) {
    switch (status) {
      case NfcScanStatus.success:
        return const Icon(Icons.check_circle, size: 48, color: Colors.green);
      case NfcScanStatus.failed:
        return const Icon(Icons.error_outline, size: 48, color: Colors.red);
      case NfcScanStatus.scanning:
        return Icon(
          Icons.nfc,
          size: 48,
          color: _getBorderColor(status, Theme.of(context).colorScheme),
        );
      default:
        // Use the NFC image from assets
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            'assets/images/nfc.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
        );
    }
  }

  Widget _buildStatusIndicator(
    NfcScanState nfcState,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        // Status message with enhanced typography
        Text(
          nfcState.message,
          style: textTheme.bodyLarge?.copyWith(
            color: _getStatusTextColor(nfcState.status, colorScheme),
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),

        // Loading indicator for scanning state
        if (nfcState.status == NfcScanStatus.scanning) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ],

        // Success checkmark
        if (nfcState.status == NfcScanStatus.success) ...[
          const SizedBox(height: 12),
          const Icon(Icons.check_circle_rounded, size: 32, color: Colors.green),
        ],

        // Error icon for failed states
        if (nfcState.status == NfcScanStatus.failed) ...[
          const SizedBox(height: 12),
          const Icon(Icons.error_rounded, size: 32, color: Colors.red),
        ],
      ],
    );
  }

  Color _getStatusTextColor(NfcScanStatus status, ColorScheme colorScheme) {
    switch (status) {
      case NfcScanStatus.success:
        return Colors.green;
      case NfcScanStatus.failed:
        return Colors.red;
      case NfcScanStatus.unavailable:
        return Colors.orange;
      default:
        return colorScheme.onSurface;
    }
  }

  Widget _buildModernActionButtons(
    NfcScanState nfcState,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    switch (nfcState.status) {
      case NfcScanStatus.scanning:
        return Column(
          children: [
            Text(
              'Keep the card near your device until scanning is complete',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: widget.onCancel,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ],
        );

      case NfcScanStatus.failed:
      case NfcScanStatus.unavailable:
        return Column(
          children: [
            Text(
              nfcState.status == NfcScanStatus.failed
                  ? 'Scan failed. Please try again or cancel to login with credentials.'
                  : 'NFC is not available on this device. Please use email login.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                if (nfcState.status == NfcScanStatus.failed)
                  FilledButton(
                    onPressed: () {
                      ref.read(nfcScanProvider.notifier).startNfcScan();
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Try Again'),
                  ),
              ],
            ),
          ],
        );

      case NfcScanStatus.success:
        return Column(
          children: [
            Text(
              'Authentication successful! Redirecting...',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        );

      default:
        return Column(
          children: [
            Text(
              'Place your NFC card on the back of your device',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    ref.read(nfcScanProvider.notifier).startNfcScan();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Start Scan'),
                ),
              ],
            ),
          ],
        );
    }
  }

  Color _getBackgroundColor(NfcScanStatus status, ColorScheme colorScheme) {
    switch (status) {
      case NfcScanStatus.success:
        return Colors.green.withValues(alpha: 0.1);
      case NfcScanStatus.scanning:
        return colorScheme.primary.withValues(alpha: 0.1);
      case NfcScanStatus.failed:
        return Colors.red.withValues(alpha: 0.1);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getBorderColor(NfcScanStatus status, ColorScheme colorScheme) {
    switch (status) {
      case NfcScanStatus.success:
        return Colors.green;
      case NfcScanStatus.scanning:
        return colorScheme.primary;
      case NfcScanStatus.failed:
        return Colors.red;
      default:
        return colorScheme.outline;
    }
  }
}
