import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bim493_barcode_store/models/product.dart';
import 'package:bim493_barcode_store/providers/product_provider.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? existing;
  final String? presetBarcode;

  const ProductFormScreen({super.key, this.existing, this.presetBarcode});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _barcode;
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _unitPrice;
  late final TextEditingController _taxRate;
  late final TextEditingController _price;
  late final TextEditingController _stockInfo;

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _barcode = TextEditingController(text: p?.barcodeNo ?? widget.presetBarcode ?? '');
    _name = TextEditingController(text: p?.productName ?? '');
    _category = TextEditingController(text: p?.category ?? '');
    _unitPrice = TextEditingController(text: p?.unitPrice.toString() ?? '');
    _taxRate = TextEditingController(text: p?.taxRate.toString() ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _stockInfo = TextEditingController(text: p?.stockInfo?.toString() ?? '');
  }

  @override
  void dispose() {
    _barcode.dispose();
    _name.dispose();
    _category.dispose();
    _unitPrice.dispose();
    _taxRate.dispose();
    _price.dispose();
    _stockInfo.dispose();
    super.dispose();
  }

  double? _parseDouble(String s) => double.tryParse(s.replaceAll(',', '.'));
  int? _parseInt(String s) => int.tryParse(s);

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final barcode = _barcode.text.trim();
    final name = _name.text.trim();
    final category = _category.text.trim();
    final unitPrice = _parseDouble(_unitPrice.text.trim())!;
    final taxRate = _parseInt(_taxRate.text.trim())!;
    final price = _parseDouble(_price.text.trim())!;
    final stockText = _stockInfo.text.trim();
    final stock = stockText.isEmpty ? null : _parseInt(stockText);

    final product = Product(
      barcodeNo: barcode,
      productName: name,
      category: category,
      unitPrice: unitPrice,
      taxRate: taxRate,
      price: price,
      stockInfo: stock,
    );

    final provider = context.read<ProductProvider>();

    try {
      if (isEdit) {
        await provider.editProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        await provider.addProduct(product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = isEdit ? 'Edit Product' : 'Add Product';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _barcode,
                  enabled: !isEdit, // edit'te barkodu kilitle
                  decoration: const InputDecoration(labelText: 'BarcodeNo'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'BarcodeNo is required';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'ProductName'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'ProductName is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Category is required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _unitPrice,
                  decoration: const InputDecoration(labelText: 'UnitPrice'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    final d = _parseDouble(s);
                    if (s.isEmpty) return 'UnitPrice is required';
                    if (d == null) return 'UnitPrice must be a number';
                    if (d < 0) return 'UnitPrice cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _taxRate,
                  decoration: const InputDecoration(labelText: 'TaxRate (int)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    final i = _parseInt(s);
                    if (s.isEmpty) return 'TaxRate is required';
                    if (i == null) return 'TaxRate must be an integer';
                    if (i < 0) return 'TaxRate cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    final d = _parseDouble(s);
                    if (s.isEmpty) return 'Price is required';
                    if (d == null) return 'Price must be a number';
                    if (d < 0) return 'Price cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _stockInfo,
                  decoration: const InputDecoration(labelText: 'StockInfo (optional)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    final i = _parseInt(s);
                    if (i == null) return 'StockInfo must be an integer';
                    if (i < 0) return 'StockInfo cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
