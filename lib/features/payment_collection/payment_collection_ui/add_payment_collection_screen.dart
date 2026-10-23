import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../customer/providers/customer_provider.dart';
import '../../home/models/bill_model.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../controllers/add_payment_collection_controller.dart';

class AddPaymentCollectionScreen extends StatefulWidget {
  final BillModel? preselectedBill;

  const AddPaymentCollectionScreen({
    super.key,
    this.preselectedBill,
  });

  @override
  State<AddPaymentCollectionScreen> createState() =>
      _AddPaymentCollectionScreenState();
}

class _AddPaymentCollectionScreenState
    extends State<AddPaymentCollectionScreen> {
  late final AddPaymentCollectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AddPaymentCollectionController(
      initialBill: widget.preselectedBill,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CompanyProvider>().fetchCompanies();
        context.read<CustomerProvider>().fetchCustomers();
      }
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: AppColors.spaceDarkBlue,
        body: Stack(
          children: [
            // 1. Top Starry Background
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: StarryHeaderBackground(height: 200),
            ),

            // 2. Main Content
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Navigation Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Screen Title
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 44.0),
                              child: Text(
                                l10n.paymentCollections,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Rounded White Content Sheet
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28.0),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28.0),
                        ),
                        child: SingleChildScrollView(
                          
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                          child: Consumer<AddPaymentCollectionController>(
                            builder: (context, controller, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 1. Selection & Summary Card
                                  _buildSelectionCard(controller, l10n),
                                  const SizedBox(height: 20),

                                  // 2. Products Section
                                  Text(
                                    '${l10n.products} ( ${controller.productLines.length.toString().padLeft(2, '0')} )',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildProductsCard(controller, l10n),
                                  const SizedBox(height: 20),

                                  // 3. Payment Inputs Card
                                  _buildPaymentInputsCard(controller, l10n),
                                  const SizedBox(height: 20),

                                  // 4. Price Breakdown Section
                                  Text(
                                    l10n.financialBreakdown,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildPriceBreakdownCard(controller, l10n),
                                  const SizedBox(height: 24),

                                  // 5. Continue Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: controller.isSubmitting
                                          ? null
                                          : () async {
                                              final success = await controller
                                                  .recordPayment();
                                              if (!context.mounted) return;
                                              if (success) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      l10n.paymentCollectionSavedSuccess,
                                                    ),
                                                    backgroundColor:
                                                        AppColors.primaryBlue,
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                                Navigator.maybePop(
                                                  context,
                                                  true,
                                                );
                                              } else if (controller
                                                      .errorMessage !=
                                                  null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      controller.errorMessage!,
                                                    ),
                                                    backgroundColor:
                                                        const Color(0xFFEF4444),
                                                    duration: const Duration(
                                                      seconds: 2,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: controller.isSubmitting
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  l10n.continueText,
                                                  style: const TextStyle(
                                                    fontSize: 15.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(AddPaymentCollectionController controller, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
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
          // Select Firm
          Text(
            l10n.selectFirm,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<CompanyProvider>(
            builder: (context, companyProv, _) {
              final firmList = companyProv.companies
                  .map((c) => c.name)
                  .where((n) => n.trim().isNotEmpty)
                  .toSet()
                  .toList();
              final effectiveFirm = firmList.contains(controller.selectedFirm)
                  ? controller.selectedFirm
                  : null;

              return _buildDropdownField(
                value: effectiveFirm,
                hint: l10n.selectFirm,
                items: firmList,
                onChanged: (val) {
                  final match = companyProv.companies
                      .where((c) => c.name == val)
                      .toList();
                  final compId =
                      match.isNotEmpty ? match.first.id : null;
                  controller.selectFirm(val, companyId: compId);
                  companyProv.selectCompanyByName(val);
                },
              );
            },
          ),
          const SizedBox(height: 14),

          // Customer
          Text(
            l10n.customer,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<CustomerProvider>(
            builder: (context, customerProv, _) {
              final companyCustomers = customerProv.getCustomersForCompany(
                companyId: controller.selectedCompanyId,
                companyName: controller.selectedFirm,
              );

              final list = companyCustomers
                  .map((c) => c.name)
                  .where((n) => n.trim().isNotEmpty)
                  .toSet()
                  .toList();

              if (controller.selectedCustomer == null &&
                  controller.selectedFirm != null &&
                  list.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (controller.selectedCustomer == null &&
                      controller.selectedFirm != null &&
                      list.isNotEmpty) {
                    controller.selectCustomer(list.first);
                  }
                });
              }

              final currentValue = list.contains(controller.selectedCustomer)
                  ? controller.selectedCustomer
                  : null;

              return _buildDropdownField(
                value: currentValue,
                hint: list.isEmpty
                    ? (controller.selectedFirm != null
                        ? l10n.noCustomersFoundFirm
                        : l10n.selectFirmFirst)
                    : l10n.selectCustomer,
                items: list,
                onChanged: (val) {
                  final matched = companyCustomers
                      .where((c) => c.name == val)
                      .toList();
                  final custId =
                      matched.isNotEmpty ? matched.first.id : null;
                  controller.selectCustomer(val, customerId: custId);
                },
              );
            },
          ),
          const SizedBox(height: 14),

          // Invoice No
          Text(
            l10n.billNumber,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: controller.selectedInvoice,
            hint: controller.isLoadingBills
                ? 'Loading invoices...'
                : (controller.invoiceOptions.isEmpty
                    ? (controller.selectedCustomer != null
                        ? 'No pending invoices'
                        : l10n.selectInvoice)
                    : l10n.selectInvoice),
            items: controller.invoiceOptions,
            onChanged: controller.selectInvoice,
          ),
          const SizedBox(height: 16),

          // 3-Column Pill Row: Total, Collected, Outstanding
          Row(
            children: [
              // Total
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalAmount,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${controller.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Collected
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalCollected,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${controller.collectedAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Outstanding
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dueAmount,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${controller.outstandingAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(
    AddPaymentCollectionController controller,
    AppLocalizations l10n,
  ) {
    final lines = controller.productLines;

    if (lines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            controller.selectedInvoice != null
                ? 'No products found in this invoice'
                : 'Select an invoice to view products',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: lines.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: Color(0xFFF1F5F9),
          indent: 14,
          endIndent: 14,
        ),
        itemBuilder: (context, index) {
          final line = lines[index];
          final lineTotal = line.lineTotal > 0
              ? line.lineTotal
              : (line.rate * line.qty * (1 + line.gstPercent / 100));

          return _buildProductRow(
            title: line.displayName,
            qty: 'Qty - ${line.qty}',
            price: '₹${lineTotal.toStringAsFixed(2)}',
          );
        },
      ),
    );
  }


  Widget _buildProductRow({
    required String title,
    required String qty,
    required String price,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          // 3D Hexagon / Box Icon Container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.view_in_ar_rounded,
                color: Color(0xFF0062E0),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Name & Qty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  qty,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          // Price
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInputsCard(AddPaymentCollectionController controller, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
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
          // Received Amount *
          Text(
            l10n.receivedAmountRequired,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: controller.receivedAmountController,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Payment Mode
          Text(
            l10n.paymentMode,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: controller.selectedPaymentMode,
            hint: l10n.paymentMode,
            items: controller.paymentModes,
            onChanged: controller.selectPaymentMode,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard(AddPaymentCollectionController controller, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
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
        children: [
          _buildBreakdownRow(
            label: l10n.invoiceTotal,
            value: controller.invoiceTotal.toStringAsFixed(2),
          ),
          const SizedBox(height: 10),
          _buildBreakdownRow(
            label: l10n.alreadyReceived,
            value: controller.alreadyReceived.toStringAsFixed(2),
          ),
          const SizedBox(height: 10),
          _buildBreakdownRow(
            label: l10n.beforePendingAmount,
            value: controller.beforePendingAmount.toStringAsFixed(2),
          ),
          const SizedBox(height: 10),
          _buildBreakdownRow(
            label: l10n.receivingNow,
            value: controller.receivingNow.toStringAsFixed(2),
          ),
          const SizedBox(height: 12),
          const Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.balanceAfterPayment,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '₹${controller.balanceAfterPayment.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A8A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final uniqueItems = items.toSet().toList();
    final effectiveValue =
        (value != null && uniqueItems.contains(value)) ? value : null;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3B82F6),
          width: 1.2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF1E293B),
            size: 24,
          ),
          items: uniqueItems.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
