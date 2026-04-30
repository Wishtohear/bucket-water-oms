class ProductModel {
  final String? id;
  final String? name;
  final String? spec;
  final String? unit;
  final double? price;
  final String? image;
  final String? category;
  final String? description;
  final bool? isActive;

  ProductModel({
    this.id,
    this.name,
    this.spec,
    this.unit,
    this.price,
    this.image,
    this.category,
    this.description,
    this.isActive,
  });

  factory ProductModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ProductModel();
    }
    return ProductModel(
      id: json['id']?.toString(),
      name: json['name'],
      spec: json['spec'] ?? json['productSpec'],
      unit: json['unit'],
      price: _parseDouble(json['price']),
      image: json['image'] ?? json['productImage'],
      category: json['category'],
      description: json['description'],
      isActive: json['isActive'] ?? json['active'],
    );
  }

  String get priceText => price != null ? '¥${price!.toStringAsFixed(2)}' : '¥0.00';
}

class InventoryModel {
  final String? id;
  final String? productId;
  final String? productName;
  final String? warehouseId;
  final String? warehouseName;
  final int? stock;
  final int? minStock;
  final int? maxStock;
  final double? price;
  final DateTime? updatedAt;

  InventoryModel({
    this.id,
    this.productId,
    this.productName,
    this.warehouseId,
    this.warehouseName,
    this.stock,
    this.minStock,
    this.maxStock,
    this.price,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return InventoryModel();
    }
    return InventoryModel(
      id: json['id']?.toString(),
      productId: json['productId']?.toString(),
      productName: json['productName'] ?? json['name'],
      warehouseId: json['warehouseId']?.toString(),
      warehouseName: json['warehouseName'],
      stock: json['stock'] ?? json['quantity'],
      minStock: json['minStock'],
      maxStock: json['maxStock'],
      price: _parseDouble(json['price']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  String get stockText => '${stock ?? 0} 桶';
  String get priceText => price != null ? '¥${price!.toStringAsFixed(2)} /桶' : '¥0.00 /桶';

  bool get isLowStock => (minStock != null && stock != null && stock! < minStock!);
  bool get isHighStock => (maxStock != null && stock != null && stock! > maxStock!);
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
