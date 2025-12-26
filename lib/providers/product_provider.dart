import 'package:flutter/foundation.dart';

import 'package:bim493_barcode_store/models/product.dart';
import 'package:bim493_barcode_store/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repo = ProductRepository();

  List<Product> _all = [];
  List<Product> get all => List.unmodifiable(_all);

  String? _activeBarcodeFilter;
  String? get activeBarcodeFilter => _activeBarcodeFilter;

  bool _loading = false;
  bool get loading => _loading;

  List<Product> get visibleProducts {
    if (_activeBarcodeFilter == null || _activeBarcodeFilter!.isEmpty) {
      return all;
    }
    return all.where((p) => p.barcodeNo == _activeBarcodeFilter).toList();
  }

  Future<void> loadAll() async {
    _loading = true;
    notifyListeners();

    _all = await _repo.getAllProducts();

    _loading = false;
    notifyListeners();
  }

  Future<Product?> searchByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return null;

    final found = await _repo.getByBarcode(trimmed);
    if (found != null) {
      _activeBarcodeFilter = trimmed; // show only that one
      // optionally refresh all to ensure latest
      await loadAll();
    }
    notifyListeners();
    return found;
  }

  Future<void> clearSearch() async {
    _activeBarcodeFilter = null;
    await loadAll();
  }

  Future<void> addProduct(Product product) async {
    await _repo.insertProduct(product);
    _activeBarcodeFilter = null;
    await loadAll();
  }

  Future<void> editProduct(Product product) async {
    await _repo.updateProduct(product);
    await loadAll();
  }

  Future<void> removeProduct(String barcode) async {
    await _repo.deleteProduct(barcode);
    if (_activeBarcodeFilter == barcode) _activeBarcodeFilter = null;
    await loadAll();
  }
}
