import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/discount_type.dart';
import '../../models/selected_product_model.dart';

/// Item-level calculation data
class GstLineCalculation {
  final String productId;
  final String productName;
  final int qty;
  final double rate;
  final double baseAmount; // qty * rate
  final double gstPercent;
  final double gstAmount; // (baseAmount * gstPercent) / 100
  final double lineTotal; // baseAmount + gstAmount

  const GstLineCalculation({
    required this.productId,
    required this.productName,
    required this.qty,
    required this.rate,
    required this.baseAmount,
    required this.gstPercent,
    required this.gstAmount,
    required this.lineTotal,
  });
}

/// Result of complete bill GST calculation
class GstCalculationResult {
  final double subTotal; // Taxable base amount (sum of base amounts)
  final double totalGst; // Total GST amount across all items
  final double cgst; // Central GST (50% of total GST)
  final double sgst; // State GST (50% of total GST)
  final double totalBeforeDiscount; // subTotal + totalGst
  final DiscountType discountType; // percentage or flat
  final double discountRate; // rate e.g. 10 (%) or 100 (Rs)
  final double discountAmount; // discount value in currency
  final double grandTotal; // totalBeforeDiscount - discountAmount
  final int totalQty;
  final int totalItems;
  final List<GstLineCalculation> lineCalculations;

  const GstCalculationResult({
    required this.subTotal,
    required this.totalGst,
    required this.cgst,
    required this.sgst,
    required this.totalBeforeDiscount,
    this.discountType = DiscountType.percentage,
    this.discountRate = 0.0,
    this.discountAmount = 0.0,
    required this.grandTotal,
    required this.totalQty,
    required this.totalItems,
    required this.lineCalculations,
  });

  static const GstCalculationResult empty = GstCalculationResult(
    subTotal: 0.0,
    totalGst: 0.0,
    cgst: 0.0,
    sgst: 0.0,
    totalBeforeDiscount: 0.0,
    discountType: DiscountType.percentage,
    discountRate: 0.0,
    discountAmount: 0.0,
    grandTotal: 0.0,
    totalQty: 0,
    totalItems: 0,
    lineCalculations: [],
  );
}

/// Centralized GST & Total Calculator for bills
class GstCal {
  /// Utility to avoid floating point precision issues using integer paise
  static double roundToTwoDecimals(double val) {
    return (val * 100.0).round() / 100.0;
  }

  /// Calculate all totals based on items, bill mode, and discount on grand total
  static GstCalculationResult calculate({
    required List<SelectedProductItem> items,
    required bool isPakka,
    DiscountType discountType = DiscountType.percentage,
    double discountRate = 0.0,
  }) {
    if (items.isEmpty) {
      return GstCalculationResult.empty;
    }

    double subTotal = 0.0;
    double totalGst = 0.0;
    int totalQty = 0;
    final List<GstLineCalculation> lines = [];

    for (final item in items) {
      final base = roundToTwoDecimals(item.rate * item.quantity);
      final effectiveGstPercent = isPakka ? (item.gstPercent > 0 ? item.gstPercent : 0.0) : 0.0;
      final lineGst = roundToTwoDecimals(base * (effectiveGstPercent / 100.0));
      final lineTotal = roundToTwoDecimals(base + lineGst);

      subTotal = roundToTwoDecimals(subTotal + base);
      totalGst = roundToTwoDecimals(totalGst + lineGst);
      totalQty += item.quantity;

      lines.add(
        GstLineCalculation(
          productId: item.id,
          productName: item.name,
          qty: item.quantity,
          rate: item.rate,
          baseAmount: base,
          gstPercent: effectiveGstPercent,
          gstAmount: lineGst,
          lineTotal: lineTotal,
        ),
      );
    }

    final cgst = roundToTwoDecimals(totalGst / 2.0);
    final sgst = roundToTwoDecimals(totalGst / 2.0);
    final totalBeforeDiscount = roundToTwoDecimals(subTotal + totalGst);

    double discountAmount = 0.0;
    if (discountRate > 0) {
      if (discountType == DiscountType.percentage) {
        discountAmount = roundToTwoDecimals(subTotal * (discountRate / 100.0));
      } else {
        discountAmount = roundToTwoDecimals(discountRate);
      }
      discountAmount = discountAmount.clamp(0.0, totalBeforeDiscount);
    }
    final grandTotal = roundToTwoDecimals(totalBeforeDiscount - discountAmount);

    return GstCalculationResult(
      subTotal: subTotal,
      totalGst: totalGst,
      cgst: cgst,
      sgst: sgst,
      totalBeforeDiscount: totalBeforeDiscount,
      discountType: discountType,
      discountRate: discountRate,
      discountAmount: discountAmount,
      grandTotal: grandTotal,
      totalQty: totalQty,
      totalItems: items.length,
      lineCalculations: lines,
    );
  }

  /// Single item calculation helper
  static GstLineCalculation calculateItem({
    required String productId,
    required String productName,
    required int qty,
    required double rate,
    required double gstPercent,
    required bool isPakka,
  }) {
    final base = roundToTwoDecimals(rate * qty);
    final effectiveGstPercent = isPakka ? (gstPercent > 0 ? gstPercent : 0.0) : 0.0;
    final gstAmount = roundToTwoDecimals(base * (effectiveGstPercent / 100.0));
    final lineTotal = roundToTwoDecimals(base + gstAmount);
    return GstLineCalculation(
      productId: productId,
      productName: productName,
      qty: qty,
      rate: rate,
      baseAmount: base,
      gstPercent: effectiveGstPercent,
      gstAmount: gstAmount,
      lineTotal: lineTotal,
    );
  }
}

/// Reusable Widget for displaying GST Price Breakdown
class GstCalSummaryWidget extends StatelessWidget {
  final GstCalculationResult calculation;
  final bool isPakka;
  final bool showDivider;

  const GstCalSummaryWidget({
    super.key,
    required this.calculation,
    required this.isPakka,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDiscount = calculation.discountAmount > 0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow(l10n?.taxableAmount ?? 'Taxable Amount', '₹${calculation.subTotal.toStringAsFixed(2)}'),
          if (isPakka && calculation.totalGst > 0) ...[
            const SizedBox(height: 10),
            _buildRow(
              l10n?.gstAmount ?? 'Total Tax (GST)',
              '₹${calculation.totalGst.toStringAsFixed(2)}',
              isHighlight: true,
            ),
          ],
          if (hasDiscount) ...[
            if (isPakka && calculation.totalGst > 0) ...[
              const SizedBox(height: 10),
              _buildRow(
                'Total (Before Discount)',
                '₹${calculation.totalBeforeDiscount.toStringAsFixed(2)}',
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Discount',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        calculation.discountType == DiscountType.percentage
                            ? '${calculation.discountRate == calculation.discountRate.roundToDouble() ? calculation.discountRate.toInt() : calculation.discountRate}% OFF'
                            : 'FLAT ₹${calculation.discountRate == calculation.discountRate.roundToDouble() ? calculation.discountRate.toInt() : calculation.discountRate}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '-₹${calculation.discountAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ],
          if (showDivider) ...[
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
            const SizedBox(height: 14),
          ],
          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.grandTotal ?? 'Grand Total',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBody,
                ),
              ),
              Text(
                '₹${calculation.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String amount, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
            color: isHighlight ? AppColors.primaryBlue : const Color(0xFF94A3B8),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? AppColors.primaryBlue : AppColors.textBody,
          ),
        ),
      ],
    );
  }
}
