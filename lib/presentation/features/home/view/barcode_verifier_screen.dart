import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/barcode_providers.dart';
import 'widgets/barcode_search_field.dart';
import 'widgets/empty_scan_state.dart';
import 'widgets/result_card.dart';
import 'widgets/scan_button.dart';
import 'widgets/scan_results_widget.dart';
import 'widgets/scanner_header.dart';

class BarcodeVerifierScreen extends ConsumerStatefulWidget {
  const BarcodeVerifierScreen({super.key});

  @override
  ConsumerState<BarcodeVerifierScreen> createState() =>
      _BarcodeVerifierScreenState();
}

class _BarcodeVerifierScreenState extends ConsumerState<BarcodeVerifierScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocusNode = FocusNode();
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;

  // Password dialog controller
  final TextEditingController _passwordController = TextEditingController();
  static const String _exitPassword = '1122';

  // Add last processed barcode to avoid duplicate navigation
  String? _lastNavigatedGtin;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();
    _scanAnimationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _processBarcode() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) return;

    ref.read(barcodeScanProvider.notifier).state = barcode;
  }

  void _clearBarcode() {
    _barcodeController.clear();
    ref.read(barcodeScanProvider.notifier).state = '';
    _barcodeFocusNode.requestFocus();
    _lastNavigatedGtin = null;
  }

  // Show password dialog when back button is pressed
  Future<bool> _onWillPop() async {
    _passwordController.clear(); // Clear any previous input

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Password to Exit'),
          content: TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              hintText: 'Password',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            autofocus: true,
            onSubmitted: (_) {
              if (_passwordController.text == _exitPassword) {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Incorrect password'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop(false);
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_passwordController.text == _exitPassword) {
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  String _getBarcodeTypeText(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.dataMatrix:
        return 'Data Matrix';
      case BarcodeType.gs1DigitalLink:
        return 'GS1 Digital Link';
      case BarcodeType.unknown:
      default:
        return 'Unknown';
    }
  }

  IconData _getBarcodeTypeIcon(BarcodeType type) {
    switch (type) {
      case BarcodeType.ean13:
        return Icons.view_agenda;
      case BarcodeType.qrCode:
        return Icons.qr_code;
      case BarcodeType.dataMatrix:
        return Icons.grid_4x4;
      case BarcodeType.gs1DigitalLink:
        return Icons.link;
      case BarcodeType.unknown:
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final barcodeResultAsync = ref.watch(barcodeResultProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Check for valid GTIN and navigate automatically
    barcodeResultAsync.whenData((result) {
      if (result.gtin != null &&
          result.gtin!.isNotEmpty &&
          result.gtin != _lastNavigatedGtin) {
        // Store the GTIN we're about to navigate to
        String gtin = result.gtin!;
        _lastNavigatedGtin = gtin;

        // Schedule navigation after the build is complete
        Future.microtask(() {
          // Clear everything
          _barcodeController.clear();
          ref.read(barcodeScanProvider.notifier).state = '';

          // Navigate to product details
          context.push('/product/$gtin');
        });
      }
    });

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GTIN Verifier'),
          backgroundColor: colorScheme.surfaceContainerHighest,
          elevation: 0,
          scrolledUnderElevation: 3,
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(right: 8.0),
          //     child: IconButton(
          //       icon: const Icon(Icons.science_outlined),
          //       tooltip: 'Test Barcodes',
          //       style: IconButton.styleFrom(
          //         foregroundColor: colorScheme.primary,
          //         backgroundColor: colorScheme.primaryContainer.withValues(
          //           alpha: 0.4,
          //         ),
          //       ),
          //       onPressed: () => context.go('/test'),
          //     ),
          //   ),
          // ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
                colorScheme.surface.withOpacity(0.9),
              ],
              stops: const [0.0, 0.7],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScannerHeader(scanAnimation: _scanAnimation),
                  const SizedBox(height: 32),
                  BarcodeSearchField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocusNode,
                    onClear: _clearBarcode,
                    onSubmitted: _processBarcode,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        // Debounce input
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_barcodeController.text == value) {
                            _processBarcode();
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Expanded(child: _buildResults(barcodeResultAsync)),
                  const SizedBox(height: 16),
                  ScanButton(
                    onPressed: () {
                      _barcodeFocusNode.requestFocus();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults(AsyncValue<BarcodeResult> barcodeResultAsync) {
    return barcodeResultAsync.when(
      data: (result) {
        if (result.scannedValue.isEmpty) {
          return const EmptyScanState();
        }
        return ScanResultsWidget(
          result: result,
          getBarcodeTypeText: _getBarcodeTypeText,
          getBarcodeTypeIcon: _getBarcodeTypeIcon,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: ResultCard(
          title: 'Error:',
          value: error.toString(),
          isError: true,
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}
