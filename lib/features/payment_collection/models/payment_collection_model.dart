import '../../home/models/bill_model.dart';

class PaymentCollectionModel {
  final String id;
  final String customerName;
  final String invoiceNumber;
  final double totalAmount;
  final double collectedAmount;
  final double outstandingAmount;
  final String status;
  final String dateSection;
  final BillModel? bill;

  const PaymentCollectionModel({
    required this.id,
    required this.customerName,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.collectedAmount,
    required this.outstandingAmount,
    this.status = 'Partial',
    required this.dateSection,
    this.bill,
  });

  factory PaymentCollectionModel.fromBillModel(
    BillModel bill, {
    required String dateSection,
  }) {
    String statusStr = 'Partial';
    if (bill.status == BillStatus.paid) {
      statusStr = 'Paid';
    } else if (bill.status == BillStatus.pending) {
      statusStr = 'Pending';
    }

    return PaymentCollectionModel(
      id: bill.id,
      customerName: bill.partyName,
      invoiceNumber: bill.invoiceNumber,
      totalAmount: bill.amount,
      collectedAmount: bill.amountPaid,
      outstandingAmount: bill.dueAmount,
      status: statusStr,
      dateSection: dateSection,
      bill: bill,
    );
  }
}

