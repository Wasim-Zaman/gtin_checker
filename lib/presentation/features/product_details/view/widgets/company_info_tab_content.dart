import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/product.dart';

class CompanyInfoTabContent extends StatelessWidget {
  final Products product;
  final ColorScheme colorScheme;
  final VoidCallback onProductInfoTap;

  const CompanyInfoTabContent({
    super.key,
    required this.product,
    required this.colorScheme,
    required this.onProductInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr =
        product.toJson().containsKey('created_at') &&
            product.toJson()['created_at'] != null
        ? _formatDate(product.toJson()['created_at'])
        : product.createdAt != null
        ? _formatDate(product.createdAt!)
        : '';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildGS1StatusCard(context, product),
          ),

          // Tabs Bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildTabButton(
                    context: context,
                    label: 'Product information',
                    isSelected: false,
                    colorScheme: colorScheme,
                    onTap: onProductInfoTap,
                  ),
                  const SizedBox(width: 8),
                  _buildTabButton(
                    context: context,
                    label: 'Company information',
                    isSelected: true,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
          ),

          // Company Information Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.companyName?.isNotEmpty ?? false
                      ? product.companyName!
                      : 'Company Information',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                // Company Details
                _buildInfoRow(
                  context: context,
                  label: 'Company Name',
                  value: product.companyName ?? '',
                  colorScheme: colorScheme,
                ),
                _buildWebsiteRow(
                  context: context,
                  label: 'Website',
                  value: product.productUrl ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licence Key',
                  value: product.licenceKey ?? product.memberID ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licence Type',
                  value: product.licenceType ?? product.gcpType ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Global Location Number (GLN)',
                  value: product.gcpGLNID ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Licensing GS1 Member Organisation',
                  value: product.moName ?? 'GS1 SAUDI ARABIA',
                  colorScheme: colorScheme,
                ),
                if (product.formattedAddress != null &&
                    product.formattedAddress!.isNotEmpty)
                  _buildInfoRow(
                    context: context,
                    label: 'Address',
                    value: product.formattedAddress!,
                    colorScheme: colorScheme,
                  ),
                _buildInfoRow(
                  context: context,
                  label: 'Date of Registration',
                  value: dateStr,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGS1StatusCard(BuildContext context, Products product) {
    final companyName = product.toJson().containsKey('companyName')
        ? product.toJson()['companyName']
        : 'Company';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'GS1',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'This number is registered to ',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  TextSpan(
                    text: companyName,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ColorScheme colorScheme,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: isSelected
              ? Border(bottom: BorderSide(color: colorScheme.primary, width: 2))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  Widget _buildWebsiteRow({
    required BuildContext context,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _launchUrl(value),
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(
      urlString.startsWith('http') ? urlString : 'https://$urlString',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
