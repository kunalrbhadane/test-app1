/// Model for the /api/size-masters?company=... response.
/// Represents available bottle sizes (e.g., 500ML, 1L, 2000ML).
class SizeMasterModel {
  final String id;
  final dynamic company; // Can be String (ID) or Map (populated object)
  final String bottleSize;
  final double preformWeightGrams;
  final int pcsPerBox;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const SizeMasterModel({
    required this.id,
    required this.company,
    required this.bottleSize,
    this.preformWeightGrams = 0.0,
    this.pcsPerBox = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Extract company ID regardless of whether company is a String or populated Map.
  String get companyId {
    if (company is String) return company as String;
    if (company is Map<String, dynamic>) {
      final map = company as Map<String, dynamic>;
      return map['_id']?.toString() ?? map['id']?.toString() ?? '';
    }
    return '';
  }

  factory SizeMasterModel.fromJson(Map<String, dynamic> json) {
    return SizeMasterModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      company: json['company'],
      bottleSize: json['bottleSize']?.toString() ?? '',
      preformWeightGrams:
          (json['preformWeightGrams'] as num?)?.toDouble() ?? 0.0,
      pcsPerBox: (json['pcsPerBox'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'company': company is Map ? company : companyId,
      'bottleSize': bottleSize,
      'preformWeightGrams': preformWeightGrams,
      'pcsPerBox': pcsPerBox,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }
}
