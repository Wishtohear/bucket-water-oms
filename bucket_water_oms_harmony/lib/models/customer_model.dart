class CustomerModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? contact;
  final String? stationId;
  final double? balance;
  final int? ticketCount;
  final int? owedBarrels;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.contact,
    this.stationId,
    this.balance,
    this.ticketCount,
    this.owedBarrels,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CustomerModel();
    }
    return CustomerModel(
      id: json['id']?.toString(),
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      contact: json['contact'],
      stationId: json['stationId']?.toString(),
      balance: _parseDouble(json['balance']),
      ticketCount: json['ticketCount'] ?? json['tickets'],
      owedBarrels: json['owedBarrels'],
      type: json['type'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  String get typeText {
    if (type != null) return type!;
    if (balance != null && balance! < 0) return '欠费';
    if (owedBarrels != null && owedBarrels! > 10) return '欠桶';
    return '常客';
  }

  String get maskedPhone {
    if (phone == null || phone!.length < 11) return phone ?? '';
    final visible = phone!.substring(0, 3);
    final end = phone!.substring(phone!.length - 4);
    return '$visible****$end';
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
