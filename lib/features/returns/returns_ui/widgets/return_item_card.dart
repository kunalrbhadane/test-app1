import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../home/models/bill_model.dart';
import '../../models/return_model.dart';

class ReturnItemCard extends StatelessWidget {
  final ReturnModel returnItem;
  final VoidCallback? onTap;

  const ReturnItemCard({
    super.key,
    required this.returnItem,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isGST = returnItem.billType == ReturnBillType.pakkaBill;
    final Color typeBg =
        isGST ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
    final Color typeColor =
        isGST ? const Color(0xFF2563EB) : const Color(0xFF64748B);

    final String? city = returnItem.customerCity;
    final String? firmName = returnItem.companyName;
    final String? createdBy = returnItem.createdByName;
    final List<BillLineItem> returnedLines = returnItem.returnedLines;
    final int returnQty = returnItem.totalReturnedQty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
          _showReturnDetailsSheet(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Row: Invoice # + Bill Type + Payment Status + Date/Time
              Row(
                children: [
                  // Invoice Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      returnItem.invoiceNumber.isNotEmpty
                          ? returnItem.invoiceNumber
                          : 'INV',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Bill Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      returnItem.typeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Payment Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBg(returnItem.paymentStatus),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      returnItem.paymentStatusLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _getStatusTextColor(returnItem.paymentStatus),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Date / Time
                  Text(
                    returnItem.time.isNotEmpty
                        ? returnItem.time
                        : returnItem.date,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Main Details Row: Icon + Party Name + City + Return Amount
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Bottle / Return Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/bottle.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF2563EB),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Party Name, Walk-in badge, Firm & City
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                returnItem.partyName,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.1,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (returnItem.isWalkIn) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.walkIn,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (firmName != null && firmName.isNotEmpty) ...[
                              const Icon(
                                Icons.storefront_outlined,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                firmName,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (city != null && city.trim().isNotEmpty) ...[
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  city,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Return Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${_formatAmount(returnItem.amount)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E3A8A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      Text(
                        l10n.returnValue,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 3. Compact Financial Mini Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMiniMetric(
                      l10n.subTotal,
                      '₹${_formatAmount(returnItem.subTotal)}',
                    ),
                    if (returnItem.gstAmount > 0)
                      _buildMiniMetric(
                        l10n.gst,
                        '₹${_formatAmount(returnItem.gstAmount)}',
                        valueColor: const Color(0xFF2563EB),
                      ),
                    _buildMiniMetric(
                      l10n.billTotal,
                      '₹${_formatAmount(returnItem.originalTotalAmount)}',
                    ),
                    _buildMiniMetric(
                      l10n.paid,
                      '₹${_formatAmount(returnItem.amountPaid)}',
                      valueColor: const Color(0xFF16A34A),
                    ),
                    _buildMiniMetric(
                      l10n.due,
                      '₹${_formatAmount(returnItem.dueAmount)}',
                      valueColor: returnItem.dueAmount > 0
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF16A34A),
                    ),
                    _buildMiniMetric(l10n.paymentMode, returnItem.paymentMode),
                  ],
                ),
              ),

              // 4. Returned Items Detail List
              if (returnedLines.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_return_outlined,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.returnedProducts,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${l10n.totalRtn}: $returnQty ${l10n.pcs}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...returnedLines.map((line) {
                        return Padding(
                           padding: const EdgeInsets.only(bottom: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      line.displayName,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${line.returnedQty}/${line.qty} ${l10n.returned}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                  if (line.rate > 0) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '@ ₹${line.rate.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (line.reason != null &&
                                  line.reason!.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 11,
                                      color: Color(0xFFE11D48),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${l10n.reason}: ${line.reason}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFEF4444),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              // 5. Footer: Created By
              if (createdBy != null && createdBy.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      size: 12,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${l10n.billedBy}: $createdBy',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  void _showReturnDetailsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bill = returnItem.billModel;
    if (bill == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        returnItem.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        returnItem.time.isNotEmpty
                            ? '${returnItem.date} | ${returnItem.time}'
                            : returnItem.date,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusBg(returnItem.paymentStatus),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      returnItem.paymentStatusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _getStatusTextColor(returnItem.paymentStatus),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer & Firm Info Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            _buildModalRow(l10n.customer, returnItem.partyName),
                            if (returnItem.customerCity != null &&
                                returnItem.customerCity!.isNotEmpty)
                              _buildModalRow(l10n.city, returnItem.customerCity!),
                            if (returnItem.companyName != null)
                              _buildModalRow(l10n.firm, returnItem.companyName!),
                            if (returnItem.createdByName != null)
                              _buildModalRow(l10n.billedBy, returnItem.createdByName!),
                            _buildModalRow(l10n.paymentMode, returnItem.paymentMode),
                            _buildModalRow(l10n.billType, returnItem.typeLabel),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Financial Breakdown Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            _buildModalRow(l10n.subTotal, '₹${bill.subTotal.toStringAsFixed(2)}'),
                            _buildModalRow(l10n.gstAmount, '₹${bill.gstAmount.toStringAsFixed(2)}'),
                            _buildModalRow(l10n.totalAmount, '₹${bill.amount.toStringAsFixed(2)}', isBold: true),
                            const Divider(height: 14, color: Color(0xFFE2E8F0)),
                            _buildModalRow(l10n.paidSoFar, '₹${bill.amountPaid.toStringAsFixed(2)}', valueColor: const Color(0xFF16A34A)),
                            _buildModalRow(l10n.totalDue, '₹${bill.dueAmount.toStringAsFixed(2)}', valueColor: bill.dueAmount > 0 ? const Color(0xFFE11D48) : const Color(0xFF16A34A), isBold: true),
                            _buildModalRow(l10n.returnValue, '₹${_formatAmount(returnItem.amount)}', valueColor: const Color(0xFF2563EB), isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Line items list
                      Text(
                        l10n.productsInBill,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...bill.lines.map((line) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: line.returnedQty > 0
                                ? const Color(0xFFFEF2F2)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: line.returnedQty > 0
                                  ? const Color(0xFFFECACA)
                                  : const Color(0xFFF1F5F9),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      line.displayName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${line.lineTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${l10n.quantity}: ${line.qty} | ${l10n.rate}: ₹${line.rate.toStringAsFixed(0)} (+${line.gstPercent.toStringAsFixed(0)}% GST)',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  if (line.returnedQty > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${l10n.totalRtn}: ${line.returnedQty}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (line.reason != null &&
                                  line.reason!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.reason}: ${line.reason}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      final parts = amount.toInt().toString().split('');
      final buffer = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 &&
            (parts.length - i) % 3 == 0 &&
            (parts.length - i) != parts.length) {
          buffer.write(',');
        }
        buffer.write(parts[i]);
      }
      return buffer.toString();
    } else {
      return amount.toStringAsFixed(2);
    }
  }

  Color _getStatusBg(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return const Color(0xFFDCFCE7);
      case BillStatus.partial:
        return const Color(0xFFFEF3C7);
      case BillStatus.pending:
        return const Color(0xFFFEE2E2);
    }
  }

  Color _getStatusTextColor(BillStatus status) {
    switch (status) {
      case BillStatus.paid:
        return const Color(0xFF16A34A);
      case BillStatus.partial:
        return const Color(0xFFD97706);
      case BillStatus.pending:
        return const Color(0xFFEF4444);
    }
  }
}
