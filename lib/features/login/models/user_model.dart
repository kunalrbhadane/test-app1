class CompanyModel {
  final String id;
  final String name;
  final String? shortCode;

  const CompanyModel({
    required this.id,
    required this.name,
    this.shortCode,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortCode: json['shortCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (shortCode != null) 'shortCode': shortCode,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String role;
  final String? mobile;
  final CompanyModel? company;
  final List<CompanyModel> companies;
  final bool canAccessKaccha;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.mobile,
    this.company,
    this.companies = const [],
    this.canAccessKaccha = false,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final Map<String, dynamic> userJson = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : ((json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json);

    CompanyModel? singleCompany;
    List<CompanyModel> compList = [];

    final compData = userJson['companies'] ?? json['companies'];
    if (compData != null) {
      if (compData is Map<String, dynamic>) {
        singleCompany = CompanyModel.fromJson(compData);
        compList = [singleCompany];
      } else if (compData is List) {
        compList = compData
            .map((e) => CompanyModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (compList.isNotEmpty) {
          singleCompany = compList.first;
        }
      }
    }

    final singleCompData = userJson['company'] ?? json['company'];
    if (singleCompData != null && singleCompData is Map<String, dynamic>) {
      singleCompany = CompanyModel.fromJson(singleCompData);
      if (!compList.any((c) => c.id == singleCompany!.id)) {
        compList.add(singleCompany);
      }
    }

    final rawCanAccess = userJson['canAccessKaccha'] ?? json['canAccessKaccha'];

    return UserModel(
      id: userJson['_id']?.toString() ??
          userJson['id']?.toString() ??
          json['_id']?.toString() ??
          json['id']?.toString() ??
          '',
      name: userJson['name']?.toString() ?? json['name']?.toString() ?? '',
      role: userJson['role']?.toString() ?? json['role']?.toString() ?? '',
      mobile: userJson['mobile']?.toString() ?? json['mobile']?.toString(),
      company: singleCompany,
      companies: compList,
      canAccessKaccha: rawCanAccess == true ||
          rawCanAccess?.toString().toLowerCase() == 'true',
      token: token ?? userJson['token']?.toString() ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'role': role,
      if (mobile != null) 'mobile': mobile,
      if (company != null) 'company': company!.toJson(),
      if (companies.isNotEmpty)
        'companies': companies.map((e) => e.toJson()).toList(),
      'canAccessKaccha': canAccessKaccha,
      if (token != null) 'token': token,
    };
  }
}
