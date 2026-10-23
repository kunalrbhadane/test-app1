class CustomerCompanyModel {
  final String id;
  final String name;
  final String? shortCode;
  final String? gstNo;
  final String? address;
  final String? city;
  final String? role;
  final bool isActive;

  const CustomerCompanyModel({
    required this.id,
    required this.name,
    this.shortCode,
    this.gstNo,
    this.address,
    this.city,
    this.role,
    this.isActive = true,
  });

  factory CustomerCompanyModel.fromJson(dynamic json) {
    if (json is String) {
      return CustomerCompanyModel(id: json, name: '');
    }
    if (json is Map<String, dynamic>) {
      return CustomerCompanyModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        shortCode: json['shortCode']?.toString(),
        gstNo: json['gstNo']?.toString(),
        address: json['address']?.toString(),
        city: json['city']?.toString(),
        role: json['role']?.toString(),
        isActive: json['isActive'] != false,
      );
    }
    return const CustomerCompanyModel(id: '', name: '');
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
    };
  }
}

class CustomerModel {
  final String id;
  final CustomerCompanyModel? company;
  final String companyId;
  final String customerId;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? gstNo;
  final String? address;
  final String? city;
  final double creditLimit;
  final double openingBalance;
  final double outstandingBalance;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const CustomerModel({
    required this.id,
    this.company,
    this.companyId = '',
    required this.customerId,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.gstNo,
    this.address,
    this.city,
    this.creditLimit = 0.0,
    this.openingBalance = 0.0,
    this.outstandingBalance = 0.0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    CustomerCompanyModel? comp;
    String compId = '';

    if (json['company'] != null) {
      if (json['company'] is Map<String, dynamic>) {
        comp = CustomerCompanyModel.fromJson(json['company'] as Map<String, dynamic>);
        compId = comp.id;
      } else if (json['company'] is String) {
        compId = json['company'] as String;
        comp = CustomerCompanyModel(id: compId, name: '');
      }
    }

    return CustomerModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      company: comp,
      companyId: compId,
      customerId: json['customerId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactPerson: json['contactPerson']?.toString(),
      mobile: json['mobile']?.toString(),
      gstNo: json['gstNo']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] != false,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (company != null && company!.name.isNotEmpty)
        'company': company!.toJson()
      else if (companyId.isNotEmpty)
        'company': companyId,
      'customerId': customerId,
      'name': name,
      if (contactPerson != null) 'contactPerson': contactPerson,
      if (mobile != null) 'mobile': mobile,
      if (gstNo != null) 'gstNo': gstNo,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      'creditLimit': creditLimit,
      'openingBalance': openingBalance,
      'outstandingBalance': outstandingBalance,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
