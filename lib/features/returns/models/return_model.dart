import '../../home/models/bill_model.dart';

enum ReturnBillType { pakkaBill, kacchaBill }

class ReturnModel {
  final String id;
  final String partyName;
  final String invoiceNumber;
  final double amount;
  final String time;
  final String date;
  final ReturnBillType billType;
  final BillModel? billModel;

  const ReturnModel({
    required this.id,
    required this.partyName,
    required this.invoiceNumber,
    required this.amount,
    required this.time,
    required this.date,
    required this.billType,
    this.billModel,
  });

  factory ReturnModel.fromBillModel(BillModel bill) {
    String dateStr = bill.date;
    String timeStr = '';
    if (bill.date.contains('|')) {
      final parts = bill.date.split('|');
      dateStr = parts[0].trim();
      if (parts.length > 1) {
        timeStr = parts[1].trim();
      }
    }

    return ReturnModel(
      id: bill.id,
      partyName: bill.partyName,
      invoiceNumber: bill.invoiceNumber.startsWith('#')
          ? bill.invoiceNumber
          : '#${bill.invoiceNumber}',
      amount: bill.totalReturnedAmount,
      time: timeStr.isNotEmpty ? timeStr : bill.date,
      date: dateStr,
      billType: bill.type == BillType.gstInvoice
          ? ReturnBillType.pakkaBill
          : ReturnBillType.kacchaBill,
      billModel: bill,
    );
  }

  List<BillLineItem> get returnedLines =>
      billModel?.lines.where((l) => l.returnedQty > 0).toList() ?? [];

  String? get reason {
    final linesWithReason =
        returnedLines.where((l) => l.reason != null && l.reason!.trim().isNotEmpty);
    if (linesWithReason.isNotEmpty) {
      return linesWithReason.first.reason;
    }
    return null;
  }

  int get totalReturnedQty => billModel?.totalReturnedQty ?? 0;

  String get returnedItemsSummary {
    if (returnedLines.isEmpty) return '';
    if (returnedLines.length == 1) {
      final first = returnedLines.first;
      return '${first.displayName} × ${first.returnedQty}';
    }
    final first = returnedLines.first;
    final otherCount = returnedLines.length - 1;
    return '${first.displayName} +$otherCount more ($totalReturnedQty pcs)';
  }

  String get typeLabel =>
      billType == ReturnBillType.pakkaBill ? 'GST Invoice' : 'Cash Memo';

  bool get isWalkIn => billModel?.isWalkIn ?? false;
  String? get customerCity => billModel?.customerCity;
  String? get createdByName => billModel?.createdByName;
  String get paymentMode => billModel?.formattedPaymentMode ?? 'Cash';
  BillStatus get paymentStatus => billModel?.status ?? BillStatus.paid;
  String get paymentStatusLabel => billModel?.statusLabel ?? '• Paid';
  double get originalTotalAmount => billModel?.amount ?? 0.0;
  int get originalTotalQty => billModel?.totalQty ?? 0;
  double get dueAmount => billModel?.dueAmount ?? 0.0;
  double get amountPaid => billModel?.amountPaid ?? 0.0;
  String? get companyName => billModel?.companyName;
  double get subTotal => billModel?.subTotal ?? 0.0;
  double get gstAmount => billModel?.gstAmount ?? 0.0;
}
