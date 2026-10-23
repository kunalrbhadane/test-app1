import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rk_plast/features/create_bill/controllers/create_bill_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../l10n/generated/app_localizations.dart';

class Step4PaymentOptionsView extends StatelessWidget {
  final CreateBillController controller;

  const Step4PaymentOptionsView({
    super.key,
    required this.controller,
  });

  static final _formatter = NumberFormat('#,##,##0.##', 'en_IN');
  static String _formatCurrency(double amount) => _formatter.format(amount);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<CreateBillController>(
      builder: (context, ctrl, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PAYMENT OPTIONS SECTION ---
            Text(
              l10n?.stepPaymentOptions ?? 'Payment Options',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textBody,
                letterSpacing: -0.1,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                children: [
                  _buildPaymentRadioOption(
                    title: l10n?.cash ?? 'Cash',
                    mode: PaymentMode.cash,
                    selectedMode: ctrl.selectedPaymentMode,
                    onSelect: () => ctrl.selectPaymentMode(PaymentMode.cash),
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentRadioOption(
                    title: l10n?.credit ?? 'Credit',
                    mode: PaymentMode.credit,
                    selectedMode: ctrl.selectedPaymentMode,
                    onSelect: () => ctrl.selectPaymentMode(PaymentMode.credit),
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentRadioOption(
                    title: l10n?.upi ?? 'UPI',
                    mode: PaymentMode.upi,
                    selectedMode: ctrl.selectedPaymentMode,
                    onSelect: () => ctrl.selectPaymentMode(PaymentMode.upi),
                  ),
                  const SizedBox(height: 14),
                  _buildPaymentRadioOption(
                    title: l10n?.bankTransfer ?? 'Bank',
                    mode: PaymentMode.bank,
                    selectedMode: ctrl.selectedPaymentMode,
                    onSelect: () => ctrl.selectPaymentMode(PaymentMode.bank),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. AMOUNT RECEIVED & DUE AMOUNT CARD ---
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
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: ctrl.amountReceivedController,
                builder: (context, val, _) {
                  final totalAmount = (ctrl.grandTotalAmount * 100.0).round() / 100.0;
                  final receivedText = val.text.trim();
                  final rawReceived = double.tryParse(receivedText) ?? 0.0;
                  final received = (rawReceived * 100.0).round() / 100.0;
                  final due = ((totalAmount - received) * 100.0).round() / 100.0;
                  final isFullyPaid = due <= 0.009;
                  final displayDue = due < 0 ? 0.0 : due;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Label on Left, Due Amount Chip on Right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n?.amountPaid ?? 'Amount Received',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLabel,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              if (!isFullyPaid) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => ctrl.payFullAmount(),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Pay Full',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          InkWell(
                            onTap: isFullyPaid ? null : () => ctrl.payFullAmount(),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isFullyPaid
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isFullyPaid
                                      ? const Color(0xFF86EFAC)
                                      : const Color(0xFFFCA5A5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isFullyPaid
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.info_outline_rounded,
                                    size: 13,
                                    color: isFullyPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${l10n?.dueAmount ?? "Remaining"}: ₹${_formatCurrency(displayDue)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isFullyPaid
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Text Field with Live Validation
                      CustomTextField(
                        hintText: '0',
                        controller: ctrl.amountReceivedController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                        validator: (val) {
                          final text = val?.trim() ?? '';
                          if (text.isEmpty) {
                            return l10n?.pleaseEnterAmount ?? 'Please enter amount received';
                          }
                          final amount = double.tryParse(text);
                          if (amount == null) {
                            return l10n?.pleaseEnterAmount ?? 'Please enter a valid amount';
                          }
                          if (amount < 0) {
                            return 'Amount cannot be negative';
                          }
                          if (amount - totalAmount > 0.01) {
                            return 'Amount cannot exceed total (₹${_formatCurrency(totalAmount)})';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPaymentRadioOption({
    required String title,
    required PaymentMode mode,
    required PaymentMode selectedMode,
    required VoidCallback onSelect,
  }) {
    final isSelected = selectedMode == mode;
    const Color activeGreen = Color(0xFF16A34A);
    const Color inactiveGrey = Color(0xFF94A3B8);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Custom Radio Circle
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeGreen : inactiveGrey,
                  width: isSelected ? 6 : 1.8,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title Text
            Text(
              title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeGreen : const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
