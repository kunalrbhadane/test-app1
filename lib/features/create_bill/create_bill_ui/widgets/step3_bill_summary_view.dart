import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rk_plast/features/create_bill/controllers/create_bill_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../models/discount_type.dart';
import 'gst_cal.dart';

class Step3BillSummaryView extends StatelessWidget {
  final CreateBillController controller;

  const Step3BillSummaryView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CreateBillController>(
      builder: (context, ctrl, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BILL SUMMARY SECTION ---
            Text(
              l10n?.stepBillSummary ?? 'Bill Summary',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 12),

            Container(
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
                  Text(
                    l10n?.chooseBillType ?? 'Bill Information',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Item 1: Bill Type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/invoice_2.png',
                            width: 22,
                            height: 22,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.description_outlined,
                              color: Color(0xFF0284C7),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n?.chooseBillType ?? 'Bill type',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ctrl.selectedBillType == CreateBillType.kacchaBill
                                  ? (l10n?.kacchaBill ?? 'Kaccha Bill ( Cash Memo )')
                                  : (l10n?.pakkaBill ?? 'Pakka Bill ( GST - Invoice )'),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Item 2: Customer
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: Color(0xFF0284C7),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n?.customer ?? 'Customer',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              ctrl.walkInNameController.text.trim().isNotEmpty
                                  ? ctrl.walkInNameController.text.trim()
                                  : (ctrl.selectedCustomer ?? (l10n?.walkInCustomer ?? 'Walk-in Customer')),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. PRODUCTS SECTION ---
            Text(
              l10n?.products ?? 'Products',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 12),

            Container(
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
              child: ctrl.selectedProductsList.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          l10n?.noProductsAddedYet ?? 'No products selected',
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: ctrl.selectedProductsList.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFF1F5F9),
                      ),
                      itemBuilder: (context, index) {
                        final item = ctrl.selectedProductsList[index];
                        final isPakka = ctrl.selectedBillType == CreateBillType.pakkaBill;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 14.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Bottle Product Icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/bottle.png',
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Color(0xFF0284C7),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name & Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textBody,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Qty: ${item.quantity}  •  ₹${item.rate.toStringAsFixed(2)}${isPakka && item.gstPercent > 0 ? '  •  GST ${item.gstPercent.toStringAsFixed(0)}%' : ''}',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),

                              // Amount
                              Text(
                                '₹${_formatAmount(item.totalAmount)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // --- 3. DISCOUNT SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBody,
                    letterSpacing: -0.1,
                  ),
                ),
                if (ctrl.discountRate > 0)
                  InkWell(
                    onTap: () => ctrl.clearDiscount(),
                    borderRadius: BorderRadius.circular(4),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Container(
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
                  // Type selection: Percentage (%) or Flat (₹)
                  Row(
                    children: [
                      Expanded(
                        child: _buildDiscountTypeOption(
                          context,
                          title: 'Percentage (%)',
                          icon: Icons.percent_rounded,
                          isSelected: ctrl.discountType == DiscountType.percentage,
                          onTap: () => ctrl.setDiscountType(DiscountType.percentage),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDiscountTypeOption(
                          context,
                          title: 'Flat Amount (₹)',
                          icon: Icons.currency_rupee_rounded,
                          isSelected: ctrl.discountType == DiscountType.flat,
                          onTap: () => ctrl.setDiscountType(DiscountType.flat),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Input Box
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ctrl.discountRate > 0
                            ? AppColors.primaryBlue
                            : const Color(0xFFE2E8F0),
                        width: ctrl.discountRate > 0 ? 1.5 : 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Icon(
                          ctrl.discountType == DiscountType.percentage
                              ? Icons.percent_rounded
                              : Icons.currency_rupee_rounded,
                          size: 18,
                          color: ctrl.discountRate > 0
                              ? AppColors.primaryBlue
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: ctrl.discountRateController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                            ],
                            decoration: InputDecoration(
                              hintText: ctrl.discountType == DiscountType.percentage
                                  ? 'Enter discount % (e.g. 10)'
                                  : 'Enter flat discount ₹ (e.g. 500)',
                              hintStyle: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                            onChanged: (val) => ctrl.setDiscountRateFromString(val),
                          ),
                        ),
                        if (ctrl.discountRate > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-₹${ctrl.discountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ctrl.discountType == DiscountType.percentage
                        ? 'Discount (${ctrl.discountRate == ctrl.discountRate.roundToDouble() ? ctrl.discountRate.toInt() : ctrl.discountRate}%) is calculated on taxable subtotal'
                        : 'Flat discount is deducted directly from Grand Total',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- 4. PRICE BREAKDOWN SECTION ---
            Text(
              l10n?.financialBreakdown ?? 'Price Breakdown',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 12),

            GstCalSummaryWidget(
              calculation: ctrl.gstCalculation,
              isPakka: ctrl.selectedBillType == CreateBillType.pakkaBill,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscountTypeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primaryBlue : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }



  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }
}
