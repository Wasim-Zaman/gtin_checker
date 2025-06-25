import 'package:flutter/material.dart';

class BarcodeSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;
  final VoidCallback onSubmitted;
  final ValueChanged<String> onChanged;

  const BarcodeSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onClear,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          labelText: 'Barcode',
          labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          hintText: 'Scan or enter barcode',
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(Icons.qr_code, color: colorScheme.primary),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            color: colorScheme.onSurfaceVariant,
            onPressed: onClear,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}
