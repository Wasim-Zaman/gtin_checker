import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../../models/product.dart';

class ProductInfoTabContent extends StatelessWidget {
  final Products product;
  final ColorScheme colorScheme;
  final VoidCallback onCompanyInfoTap;

  const ProductInfoTabContent({
    super.key,
    required this.product,
    required this.colorScheme,
    required this.onCompanyInfoTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    isSelected: true,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildTabButton(
                    context: context,
                    label: 'Company information',
                    isSelected: false,
                    colorScheme: colorScheme,
                    onTap: onCompanyInfoTap,
                  ),
                ],
              ),
            ),
          ),

          // Product Information Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productnameenglish ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProductImage(context, product, colorScheme),
                const SizedBox(height: 32),

                // Product Details
                _buildInfoRow(
                  context: context,
                  label: 'GTIN',
                  value: product.barcode ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Brand Name',
                  value: product.brandName ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Product Description',
                  value: product.productnameenglish ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Global product category',
                  value: product.gpcCode ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Net Content',
                  value: product.size != null && product.unit != null
                      ? '${product.size} ${product.unit}'
                      : product.size ?? '',
                  colorScheme: colorScheme,
                ),
                _buildInfoRow(
                  context: context,
                  label: 'Country',
                  value: product.countrySale ?? '',
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

  Widget _buildProductImage(
    BuildContext context,
    Products product,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: product.frontImage != null && product.frontImage!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: product.frontImage!,
                  fit: BoxFit.contain,
                  httpHeaders: {
                    'Accept':
                        'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                    'Accept-Language': 'en-US,en;q=0.9',
                    'Referer': 'https://gs1.org.sa/',
                    'User-Agent':
                        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
                    'sec-ch-ua':
                        '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
                    'sec-ch-ua-mobile': '?0',
                    'sec-ch-ua-platform': '"macOS"',
                  },
                  placeholder: (context, url) =>
                      _buildImagePlaceholder(colorScheme),
                  errorWidget: (context, url, error) =>
                      _buildImageWithFallback(url, colorScheme),
                )
              : _buildImageError(colorScheme),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerLowest,
      child: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }

  // Try to load image using http client with custom headers as fallback
  Widget _buildImageWithFallback(String url, ColorScheme colorScheme) {
    return FutureBuilder(
      future: _loadImageWithCustomHeaders(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildImagePlaceholder(colorScheme);
        } else if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(snapshot.data!, fit: BoxFit.contain);
        } else {
          return _buildImageError(colorScheme);
        }
      },
    );
  }

  Future<Uint8List?> _loadImageWithCustomHeaders(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept':
              'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
          'Referer': 'https://gs1.org.sa/',
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36',
          'sec-ch-ua':
              '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"macOS"',
        },
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading image with custom headers: $e');
      }
      return null;
    }
  }

  Widget _buildImageError(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported,
              size: 60,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
