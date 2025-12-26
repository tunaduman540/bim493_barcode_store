import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'bim493_store.db';
  static const int _dbVersion = 1;

  static const String productTable = 'ProductTable';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $productTable (
            BarcodeNo TEXT PRIMARY KEY,
            ProductName TEXT NOT NULL,
            Category TEXT NOT NULL,
            UnitPrice REAL NOT NULL,
            TaxRate INTEGER NOT NULL,
            Price REAL NOT NULL,
            StockInfo INTEGER
          )
        ''');
      },
    );

    return _db!;
  }
}
