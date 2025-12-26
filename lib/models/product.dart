class Product {
  final String barcodeNo; // PK
  final String productName;
  final String category;
  final double unitPrice;
  final int taxRate;
  final double price;
  final int? stockInfo; // nullable

  const Product({
    required this.barcodeNo,
    required this.productName,
    required this.category,
    required this.unitPrice,
    required this.taxRate,
    required this.price,
    this.stockInfo,
  });

  Map<String, Object?> toMap() {
    return {
      'BarcodeNo': barcodeNo,
      'ProductName': productName,
      'Category': category,
      'UnitPrice': unitPrice,
      'TaxRate': taxRate,
      'Price': price,
      'StockInfo': stockInfo,
    };
  }

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      barcodeNo: (map['BarcodeNo'] as String),
      productName: (map['ProductName'] as String),
      category: (map['Category'] as String),
      unitPrice: (map['UnitPrice'] as num).toDouble(),
      taxRate: (map['TaxRate'] as num).toInt(),
      price: (map['Price'] as num).toDouble(),
      stockInfo: map['StockInfo'] == null ? null : (map['StockInfo'] as num).toInt(),
    );
  }

  Product copyWith({
    String? barcodeNo,
    String? productName,
    String? category,
    double? unitPrice,
    int? taxRate,
    double? price,
    int? stockInfo, // pass null explicitly if you want
    bool stockInfoToNull = false,
  }) {
    return Product(
      barcodeNo: barcodeNo ?? this.barcodeNo,
      productName: productName ?? this.productName,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      price: price ?? this.price,
      stockInfo: stockInfoToNull ? null : (stockInfo ?? this.stockInfo),
    );
  }
}
