import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../providers/product_providers.dart';
import 'widgets/company_info_tab_content.dart';
import '../../../widgets/product_additional_info_tab.dart';
import 'widgets/product_error_state.dart';
import 'widgets/product_info_tab_content.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String barcode;

  const ProductDetailsScreen({super.key, required this.barcode});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.barcode));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        scrolledUnderElevation: 3,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _mainTabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Product Info'),
            Tab(icon: Icon(Icons.business), text: 'Company Info'),
            Tab(
              icon: Icon(Icons.dashboard_customize_outlined),
              text: 'Additional Info',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              colorScheme.surface.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: productAsync.when(
          data: (product) {
            if (product == null) {
              return const ProductErrorState();
            }

            // If product data is not available but company info exists, show only Company Info tab
            final hasProductData =
                product.toJson().containsKey('ProductDataAvailable')
                ? product.toJson()['ProductDataAvailable']
                : true;

            if (!hasProductData) {
              // Automatically switch to Company Info tab
              _mainTabController.animateTo(1);

              return TabBarView(
                controller: _mainTabController,
                children: [
                  const ProductErrorState(), // Product Info tab is empty
                  CompanyInfoTabContent(
                    product: product,
                    colorScheme: colorScheme,
                    onProductInfoTap: () {
                      _mainTabController.animateTo(0);
                    },
                  ), // Company Info tab
                  ProductAdditionalInfoTab(
                    product: product,
                  ), // Additional Info tab
                ],
              );
            }

            return TabBarView(
              controller: _mainTabController,
              children: [
                ProductInfoTabContent(
                  product: product,
                  colorScheme: colorScheme,
                  onCompanyInfoTap: () {
                    _mainTabController.animateTo(1);
                  },
                ),
                CompanyInfoTabContent(
                  product: product,
                  colorScheme: colorScheme,
                  onProductInfoTap: () {
                    _mainTabController.animateTo(0);
                  },
                ),
                ProductAdditionalInfoTab(product: product),
              ],
            );
          },
          loading: () => _buildLoadingShimmer(context),
          error: (error, stackTrace) => ProductErrorState(error: error),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),

            // Title placeholder
            Container(
              height: 32,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),

            // Brand placeholder
            Container(
              height: 24,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 16),

            // Chips placeholder
            Row(
              children: [
                Container(
                  height: 32,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Divider placeholder
            Container(height: 1, width: double.infinity, color: Colors.white),
            const SizedBox(height: 16),

            // Detail rows
            for (int i = 0; i < 8; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
