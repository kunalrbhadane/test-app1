class CompanyBillingMetrics {
  final int totalInvoices;
  final double totalSales;
  final int totalStock;
  final int lowStockAlert;

  const CompanyBillingMetrics({
    this.totalInvoices = 0,
    this.totalSales = 0.0,
    this.totalStock = 0,
    this.lowStockAlert = 0,
  });

  factory CompanyBillingMetrics.fromJson(Map<String, dynamic> json) {
    return CompanyBillingMetrics(
      totalInvoices: (json['totalInvoices'] as num?)?.toInt() ?? 0,
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      lowStockAlert: (json['lowStockAlert'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalInvoices': totalInvoices,
      'totalSales': totalSales,
      'totalStock': totalStock,
      'lowStockAlert': lowStockAlert,
    };
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String? shortCode;
  final String? gstNo;
  final String? address;
  final String? city;
  final String? role;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final CompanyBillingMetrics? billingMetrics;

  const CompanyModel({
    required this.id,
    required this.name,
    this.shortCode,
    this.gstNo,
    this.address,
    this.city,
    this.role,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.billingMetrics,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortCode: json['shortCode']?.toString(),
      gstNo: json['gstNo']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      role: json['role']?.toString(),
      isActive: json['isActive'] != false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      billingMetrics: json['billingMetrics'] != null &&
              json['billingMetrics'] is Map<String, dynamic>
          ? CompanyBillingMetrics.fromJson(
              json['billingMetrics'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (shortCode != null) 'shortCode': shortCode,
      if (gstNo != null) 'gstNo': gstNo,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (role != null) 'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (billingMetrics != null) 'billingMetrics': billingMetrics!.toJson(),
    };
  }
}
