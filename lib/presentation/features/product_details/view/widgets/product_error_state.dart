import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductErrorState extends StatelessWidget {
  final Object? error;

  const ProductErrorState({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (error == null) {
      return _buildEmptyState(context, colorScheme);
    }

    // Extract meaningful information from the error
    final String errorMessage = _getErrorMessage(error!);
    final String userFriendlyTitle = _getUserFriendlyErrorTitle(error!);
    final IconData errorIcon = _getErrorIcon(error!);
    final bool isNotFoundError = _isNotFoundError(error!);

    return Center(
      child: Card(
        elevation: 0,
        color: isNotFoundError
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : colorScheme.errorContainer.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isNotFoundError
                ? colorScheme.outlineVariant
                : colorScheme.error.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isNotFoundError
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
                      : colorScheme.errorContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorIcon,
                  size: 40,
                  color: isNotFoundError
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                userFriendlyTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isNotFoundError
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No product found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We couldn\'t find any product with this barcode',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => context.go('/'),
                child: const Text('Return to Scanner'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for error handling
  bool _isNotFoundError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('404') ||
        errorString.contains('not found') ||
        errorString.contains('no product');
  }

  String _getUserFriendlyErrorTitle(Object error) {
    if (_isNotFoundError(error)) {
      return 'Product Not Found';
    } else if (error.toString().toLowerCase().contains('timeout')) {
      return 'Connection Timeout';
    } else if (error.toString().toLowerCase().contains('network')) {
      return 'Network Error';
    } else {
      return 'Error Loading Product';
    }
  }

  String _getErrorMessage(Object error) {
    if (_isNotFoundError(error)) {
      return 'This barcode is not registered in the GS1 database. Please verify the barcode or try scanning a different product.';
    } else if (error.toString().toLowerCase().contains('timeout')) {
      return 'The connection timed out. Please check your internet connection and try again.';
    } else if (error.toString().toLowerCase().contains('network')) {
      return 'There was a problem with your network connection. Please check your internet and try again.';
    } else {
      // For debugging purposes, we'll still show the actual error
      // But with a more user-friendly introduction
      return 'Something went wrong while fetching the product information.';
    }
  }

  IconData _getErrorIcon(Object error) {
    if (_isNotFoundError(error)) {
      return Icons.search_off_outlined;
    } else if (error.toString().toLowerCase().contains('timeout') ||
        error.toString().toLowerCase().contains('network')) {
      return Icons.wifi_off_outlined;
    } else {
      return Icons.error_outline;
    }
  }
}
