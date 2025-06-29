import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NfcScanStatus {
  ready,
  scanning,
  cardDetected,
  success,
  failed,
  unavailable,
}

class NfcScanState {
  final NfcScanStatus status;
  final String message;
  final String? cardData;
  final String? error;

  const NfcScanState({
    required this.status,
    required this.message,
    this.cardData,
    this.error,
  });

  NfcScanState copyWith({
    NfcScanStatus? status,
    String? message,
    String? cardData,
    String? error,
  }) {
    return NfcScanState(
      status: status ?? this.status,
      message: message ?? this.message,
      cardData: cardData ?? this.cardData,
      error: error ?? this.error,
    );
  }
}

class NfcScanNotifier extends StateNotifier<NfcScanState> {
  NfcScanNotifier()
    : super(
        const NfcScanState(
          status: NfcScanStatus.ready,
          message: 'Ready to scan',
        ),
      );

  Future<void> startNfcScan() async {
    state = state.copyWith(
      status: NfcScanStatus.scanning,
      message: 'Hold your NFC card near the device',
    );

    try {
      // Check NFC availability
      var availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        state = state.copyWith(
          status: NfcScanStatus.unavailable,
          message: 'NFC not available on this device',
        );
        return;
      }

      // Start NFC session
      var tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 30),
        iosMultipleTagMessage: "Multiple tags detected!",
        iosAlertMessage: "Scan your NFC card",
      );

      state = state.copyWith(
        status: NfcScanStatus.cardDetected,
        message: 'Card detected! Processing...',
      );

      // Extract card data (use the tag ID as the NFC number)
      String cardData = tag.id;

      // If no ID, try other methods
      if (cardData.isEmpty && tag.standard == "ISO 14443 Type A") {
        // Try to read NDEF data if available
        if (tag.ndefAvailable ?? false) {
          try {
            var ndefRecords = await FlutterNfcKit.readNDEFRecords();
            if (ndefRecords.isNotEmpty) {
              cardData = ndefRecords.first.payload.toString();
            }
          } catch (e) {
            // If NDEF reading fails, continue with tag ID
          }
        }
      }

      // Finish NFC session
      await FlutterNfcKit.finish(iosAlertMessage: "Card scanned successfully!");

      if (cardData.isNotEmpty) {
        state = state.copyWith(
          status: NfcScanStatus.success,
          message: 'Card scanned successfully!',
          cardData: cardData,
        );

        // Wait a moment to show success
        await Future.delayed(const Duration(milliseconds: 1500));
      } else {
        state = state.copyWith(
          status: NfcScanStatus.failed,
          message: 'No data found on card. Please try again.',
          error: 'No card data found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: NfcScanStatus.failed,
        message: 'Scan failed: ${e.toString()}',
        error: e.toString(),
      );
      await FlutterNfcKit.finish(iosErrorMessage: "Scan failed");
    }
  }

  void reset() {
    state = const NfcScanState(
      status: NfcScanStatus.ready,
      message: 'Ready to scan',
    );
  }
}

final nfcScanProvider = StateNotifierProvider<NfcScanNotifier, NfcScanState>((
  ref,
) {
  return NfcScanNotifier();
});
