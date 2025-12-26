import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bim493_barcode_store/providers/product_provider.dart';
import 'package:bim493_barcode_store/screens/product_form_screen.dart';
import 'package:bim493_barcode_store/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _barcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barcode cannot be empty')),
      );
      return;
    }

    final provider = context.read<ProductProvider>();
    final found = await provider.searchByBarcode(barcode);

    if (found == null) {
      if (!mounted) return;
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Product not found'),
          content: const Text('Product not found. Would you like to add a new product?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
          ],
        ),
      );

      if (result == true && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductFormScreen(presetBarcode: barcode),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(String barcode) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm delete'),
        content: Text('Are you sure you want to delete product $barcode?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (ok == true && mounted) {
      await context.read<ProductProvider>().removeProduct(barcode);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.visibleProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BIM 493 Store'),
        actions: [
          if (provider.activeBarcodeFilter != null)
            IconButton(
              tooltip: 'Clear search',
              onPressed: () {
                _barcodeController.clear();
                provider.clearSearch();
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _search(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _search,
                    child: const Text('Search'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (provider.loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    int crossAxisCount = 1;
                    if (w >= 1000) crossAxisCount = 3;
                    else if (w >= 650) crossAxisCount = 2;

                    if (products.isEmpty) {
                      return const Center(child: Text('No products yet.'));
                    }

                    return GridView.builder(
                      itemCount: products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return ProductCard(
                          product: p,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductFormScreen(existing: p),
                              ),
                            );
                          },
                          onDelete: () => _confirmDelete(p.barcodeNo),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
