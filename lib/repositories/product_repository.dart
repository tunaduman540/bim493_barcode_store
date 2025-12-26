import 'package:sqflite/sqflite.dart';

import 'package:bim493_barcode_store/db/app_database.dart';
import 'package:bim493_barcode_store/models/product.dart';

class ProductRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<void> insertProduct(Product product) async {
    final db = await _db.database;

    try {
      await db.insert(
        AppDatabase.productTable,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort, // duplicate -> throw
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Duplicate barcode. This product already exists.');
      }
      rethrow;
    }
  }

  Future<List<Product>> getAllProducts() async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.productTable,
      orderBy: 'ProductName ASC',
    );
    return rows.map((e) => Product.fromMap(e)).toList();
  }

  Future<Product?> getByBarcode(String barcode) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.productTable,
      where: 'BarcodeNo = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<void> updateProduct(Product product) async {
    final db = await _db.database;
    await db.update(
      AppDatabase.productTable,
      product.toMap(),
      where: 'BarcodeNo = ?',
      whereArgs: [product.barcodeNo],
    );
  }

  Future<void> deleteProduct(String barcode) async {
    final db = await _db.database;
    await db.delete(
      AppDatabase.productTable,
      where: 'BarcodeNo = ?',
      whereArgs: [barcode],
    );
  }
}
