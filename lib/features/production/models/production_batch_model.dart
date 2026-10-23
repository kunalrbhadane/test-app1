class ProductionBatchModel {
  final int totalPreformPiecesExpected;
  final int totalRejectionCount;
  final String batchNumber;
  final String currentStage;
  final String status;
  final String sizeKey;
  final int goodBottleCount;
  final int totalGoodCount;
  final int netGoodCount;
  final int totalNetGoodCount;
  final String? finishedAt;
  final String? createdAt;

  const ProductionBatchModel({
    this.totalPreformPiecesExpected = 0,
    this.totalRejectionCount = 0,
    required this.batchNumber,
    this.currentStage = '',
    this.status = '',
    this.sizeKey = '',
    this.goodBottleCount = 0,
    this.totalGoodCount = 0,
    this.netGoodCount = 0,
    this.totalNetGoodCount = 0,
    this.finishedAt,
    this.createdAt,
  });

  factory ProductionBatchModel.fromJson(Map<String, dynamic> json) {
    return ProductionBatchModel(
      totalPreformPiecesExpected:
          (json['totalPreformPiecesExpected'] as num?)?.toInt() ?? 0,
      totalRejectionCount:
          (json['totalRejectionCount'] as num?)?.toInt() ?? 0,
      batchNumber: json['batchNumber']?.toString() ?? '',
      currentStage: json['currentStage']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sizeKey: json['sizeKey']?.toString() ?? '',
      goodBottleCount: (json['goodBottleCount'] as num?)?.toInt() ?? 0,
      totalGoodCount: (json['totalGoodCount'] as num?)?.toInt() ?? 0,
      netGoodCount: (json['netGoodCount'] as num?)?.toInt() ?? 0,
      totalNetGoodCount: (json['totalNetGoodCount'] as num?)?.toInt() ?? 0,
      finishedAt: json['finishedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPreformPiecesExpected': totalPreformPiecesExpected,
      'totalRejectionCount': totalRejectionCount,
      'batchNumber': batchNumber,
      'currentStage': currentStage,
      'status': status,
      'sizeKey': sizeKey,
      'goodBottleCount': goodBottleCount,
      'totalGoodCount': totalGoodCount,
      'netGoodCount': netGoodCount,
      'totalNetGoodCount': totalNetGoodCount,
      if (finishedAt != null) 'finishedAt': finishedAt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  ProductionBatchModel copyWith({
    int? totalPreformPiecesExpected,
    int? totalRejectionCount,
    String? batchNumber,
    String? currentStage,
    String? status,
    String? sizeKey,
    int? goodBottleCount,
    int? totalGoodCount,
    int? netGoodCount,
    int? totalNetGoodCount,
    String? finishedAt,
    String? createdAt,
  }) {
    return ProductionBatchModel(
      totalPreformPiecesExpected:
          totalPreformPiecesExpected ?? this.totalPreformPiecesExpected,
      totalRejectionCount: totalRejectionCount ?? this.totalRejectionCount,
      batchNumber: batchNumber ?? this.batchNumber,
      currentStage: currentStage ?? this.currentStage,
      status: status ?? this.status,
      sizeKey: sizeKey ?? this.sizeKey,
      goodBottleCount: goodBottleCount ?? this.goodBottleCount,
      totalGoodCount: totalGoodCount ?? this.totalGoodCount,
      netGoodCount: netGoodCount ?? this.netGoodCount,
      totalNetGoodCount: totalNetGoodCount ?? this.totalNetGoodCount,
      finishedAt: finishedAt ?? this.finishedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // --- Helper Getters ---
  DateTime? get finishedDateTime =>
      finishedAt != null ? DateTime.tryParse(finishedAt!) : null;

  DateTime? get createdDateTime =>
      createdAt != null ? DateTime.tryParse(createdAt!) : null;

  bool get isFinished => status.toLowerCase() == 'finished';

  double get rejectionPercentage {
    if (totalPreformPiecesExpected <= 0) return 0.0;
    return (totalRejectionCount / totalPreformPiecesExpected) * 100.0;
  }

  double get efficiencyPercentage {
    if (totalPreformPiecesExpected <= 0) return 0.0;
    return (totalNetGoodCount / totalPreformPiecesExpected) * 100.0;
  }

  @override
  String toString() =>
      'ProductionBatchModel(batchNumber: $batchNumber, sizeKey: $sizeKey, status: $status, netGoodCount: $netGoodCount)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductionBatchModel &&
        other.batchNumber == batchNumber &&
        other.sizeKey == sizeKey &&
        other.status == status;
  }

  @override
  int get hashCode =>
      batchNumber.hashCode ^ sizeKey.hashCode ^ status.hashCode;
}
