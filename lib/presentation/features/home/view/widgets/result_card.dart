import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;
  final bool isError;
  final IconData icon;

  const ResultCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color cardColor = highlight
        ? colorScheme.primaryContainer.withValues(alpha: 0.7)
        : isError
        ? colorScheme.errorContainer.withValues(alpha: 0.7)
        : colorScheme.surface;

    final Color iconColor = highlight
        ? colorScheme.primary
        : isError
        ? colorScheme.error
        : colorScheme.primary.withValues(alpha: 0.7);

    final Color titleColor = highlight
        ? colorScheme.onPrimaryContainer
        : isError
        ? colorScheme.error
        : colorScheme.onSurfaceVariant;

    final Color valueColor = highlight
        ? colorScheme.onPrimaryContainer
        : isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      elevation: highlight ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlight
              ? colorScheme.primary.withValues(alpha: 0.3)
              : isError
              ? colorScheme.error.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
          width: highlight || isError ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: highlight
                    ? colorScheme.primary.withValues(alpha: 0.1)
                    : isError
                    ? colorScheme.error.withValues(alpha: 0.1)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                      color: valueColor,
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
