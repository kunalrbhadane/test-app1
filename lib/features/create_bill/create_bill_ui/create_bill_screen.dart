import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../customer/providers/customer_provider.dart';
import '../../home/controllers/home_controller.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../../login/providers/auth_provider.dart';
import '../controllers/create_bill_controller.dart';
import '../models/billing_model.dart';
import '../models/draft_bill_model.dart';
import '../providers/billing_provider.dart';
import '../providers/size_master_provider.dart';
import '../../production/providers/production_provider.dart';
import '../services/draft_storage_service.dart';
import 'widgets/add_customer_form.dart';
import 'widgets/bill_type_selector_card.dart';
import 'widgets/step2_product_selection_view.dart';
import 'widgets/step3_bill_summary_view.dart';
import 'widgets/step4_payment_options_view.dart';
import 'widgets/step5_invoice_preview_view.dart';
import '../services/invoice_pdf_service.dart';
import 'bill_success_screen.dart';

class CreateBillScreen extends StatefulWidget {
  final DraftBillModel? initialDraft;

  const CreateBillScreen({super.key, this.initialDraft});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  late final CreateBillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateBillController();
    if (widget.initialDraft != null) {
      _controller.loadFromDraft(widget.initialDraft!);
    } else {
      _controller.resetAll();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CompanyProvider>().fetchCompanies();
        context.read<CustomerProvider>().fetchCustomers();
        context.read<SizeMasterProvider>().fetchAll();
        context.read<ProductionProvider>().fetchUniqueBatches();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleContinue(BuildContext context, CreateBillController controller) {
    final step = controller.currentStep;
    final l10n = AppLocalizations.of(context)!;

    // Step 1: Firm validation
    if (step == 1) {
      if (controller.selectedFirm == null ||
          controller.selectedFirm!.trim().isEmpty) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.pleaseSelectFirmFirst,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }

      if (controller.customerType == BillCustomerType.registered &&
          (controller.selectedCustomer == null ||
              controller.selectedCustomer!.trim().isEmpty)) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.pleaseSelectCustomerFirst,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Step 2: Product selection validation
    if (step == 2) {
      // If a product is selected in dropdown but "+ Add More Product" wasn't clicked, auto-add it
      if (controller.selectedProductsList.isEmpty &&
          controller.selectedProductId != null) {
        controller.addProductToList();
      }

      // Check if product list is empty
      if (controller.selectedProductsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.pleaseAddProductFirst,
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    // Step 4: Payment validation
    if (step == 4) {
      final text = controller.amountReceivedController.text.trim();
      final parsed = double.tryParse(text);
      if (text.isEmpty || parsed == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount received'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (parsed < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Amount received cannot be negative'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      if (parsed - controller.grandTotalAmount > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Amount received (₹${parsed.toStringAsFixed(parsed == parsed.roundToDouble() ? 0 : 2)}) cannot exceed total amount (₹${controller.grandTotalAmount.toStringAsFixed(controller.grandTotalAmount == controller.grandTotalAmount.roundToDouble() ? 0 : 2)})',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    if (step < controller.totalSteps) {
      controller.nextStep();
    }
  }

  Future<void> _submitBill(
    BuildContext context,
    CreateBillController controller,
  ) async {
    final billingProv = context.read<BillingProvider>();
    final companyProv = context.read<CompanyProvider>();
    final customerProv = context.read<CustomerProvider>();

    // 1. Resolve Company ID
    String companyId = controller.selectedCompanyId ?? '';
    if (companyId.isEmpty && companyProv.selectedCompany != null) {
      companyId = companyProv.selectedCompany!.id;
    }
    if (companyId.isEmpty && companyProv.companies.isNotEmpty) {
      companyId = companyProv.companies.first.id;
    }

    // 2. Resolve Customer / Walk-In
    String? customerId;
    String? walkInName;

    if (controller.customerType == BillCustomerType.walkIn) {
      final walkInText = controller.walkInNameController.text.trim();
      walkInName = walkInText.isNotEmpty ? walkInText : 'Walk-in Customer';
      customerId = null;
    } else {
      final selectedCustName = controller.selectedCustomer?.trim();
      if (selectedCustName != null && selectedCustName.isNotEmpty) {
        final matchedCustomer = customerProv.customers
            .where((c) => c.name.toLowerCase() == selectedCustName.toLowerCase())
            .toList();

        if (matchedCustomer.isNotEmpty) {
          customerId = matchedCustomer.first.id;
          walkInName = null;
        } else {
          walkInName = selectedCustName;
          customerId = null;
        }
      } else {
        walkInName = 'Walk-in Customer';
        customerId = null;
      }
    }

    // 3. Bill Mode
    final mode = controller.selectedBillType == CreateBillType.pakkaBill
        ? 'pakka'
        : 'kaccha';

    // 4. Payment Mode
    String paymentMode;
    switch (controller.selectedPaymentMode) {
      case PaymentMode.cash:
        paymentMode = 'cash';
        break;
      case PaymentMode.credit:
        paymentMode = 'credit';
        break;
      case PaymentMode.upi:
        paymentMode = 'upi';
        break;
      case PaymentMode.bank:
        paymentMode = 'bank';
        break;
    }

    if (controller.selectedProductsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one product before generating bill',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final isPakka = mode == 'pakka';

    // 5. Line items
    List<BillingLineItem> lines = controller.selectedProductsList.map((item) {
      return BillingLineItem(
        product: item.id,
        qty: item.quantity,
        rate: item.rate,
        gstPercent: isPakka ? item.gstPercent : null,
        batchNumber: item.batchNumber,
      );
    }).toList();

    // 6. Amount paid (ensure 2-decimal precision)
    final rawAmountText = controller.amountReceivedController.text.trim();
    double amountPaid = 0.0;
    if (rawAmountText.isNotEmpty) {
      final parsed = double.tryParse(rawAmountText) ?? 0.0;
      amountPaid = (parsed * 100.0).round() / 100.0;
    }
    // If user selected cash or upi and left it empty or zero while expecting full payment
    if (amountPaid <= 0 && controller.selectedPaymentMode != PaymentMode.credit && controller.grandTotalAmount > 0) {
      amountPaid = (controller.grandTotalAmount * 100.0).round() / 100.0;
    }

    try {
      final createdBill = await billingProv.createBill(
        companyId: companyId,
        mode: mode,
        walkInName: walkInName,
        customerId: customerId,
        lines: lines,
        paymentMode: paymentMode,
        amountPaid: amountPaid,
        discountType: controller.discountType.value,
        discountRate: controller.discountRate,
      );

      // If this bill was from a saved draft, clean it up
      if (controller.currentDraftId != null) {
        await DraftStorageService().deleteDraft(controller.currentDraftId!);
        if (context.mounted) {
          try {
            context.read<HomeController>().loadPendingDrafts();
          } catch (_) {}
        }
      }

      if (!context.mounted) return;

      final displayPaymentMode =
          controller.selectedPaymentMode == PaymentMode.upi
          ? 'UPI'
          : controller.selectedPaymentMode == PaymentMode.cash
          ? 'Cash'
          : controller.selectedPaymentMode == PaymentMode.credit
          ? 'Credit'
          : 'Bank';

      final now = DateTime.now();
      final displayDate =
          createdBill.date != null && createdBill.date!.length >= 10
          ? createdBill.date!.substring(0, 10)
          : '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final companyProv = context.read<CompanyProvider>();
      final customerProv = context.read<CustomerProvider>();
      final authProv = context.read<AuthProvider>();

      final userCompany = companyProv.selectedCompany ??
          (companyProv.companies.isNotEmpty
              ? companyProv.companies.first
              : null);
      final activeCompany =
          (controller.selectedCompanyId != null &&
                  controller.selectedCompanyId!.isNotEmpty)
              ? companyProv.companies
                      .where((c) => c.id == controller.selectedCompanyId)
                      .firstOrNull ??
                  userCompany
              : userCompany;

      final matchedCustomer = customerProv.customers
          .where(
            (c) =>
                c.name.toLowerCase() ==
                (controller.selectedCustomer ?? '').toLowerCase(),
          )
          .firstOrNull;

      final custFinalName = createdBill.walkInName?.isNotEmpty == true
          ? createdBill.walkInName!
          : (walkInName?.isNotEmpty == true
                ? walkInName!
                : (controller.selectedCustomer?.isNotEmpty == true
                      ? controller.selectedCustomer!
                      : controller.customerNameController.text.trim()));

      final compSubtitle = (activeCompany?.role != null &&
              activeCompany!.role!.isNotEmpty)
          ? activeCompany.role!.toUpperCase().replaceAll('_', ' ')
          : (activeCompany?.shortCode ?? '');

      final pdfData = InvoicePdfData.fromController(
        controller: controller,
        companyName:
            activeCompany?.name ??
            controller.selectedFirm ??
            '',
        companySubtitle: compSubtitle,
        companyAddress: [
          if (activeCompany?.address != null &&
              activeCompany!.address!.trim().isNotEmpty)
            activeCompany.address!.trim(),
          if (activeCompany?.city != null &&
              activeCompany!.city!.trim().isNotEmpty)
            activeCompany.city!.trim(),
        ].join(', '),
        companyGstin: activeCompany?.gstNo ?? '',
        companyCity: activeCompany?.city ?? '',
        companyPhone: '',
        customerName: custFinalName,
        customerAddress:
            matchedCustomer?.address ??
            controller.customerAddressController.text.trim(),
        customerGstin:
            matchedCustomer?.gstNo ??
            controller.customerGstinController.text.trim(),
        customerMobile:
            matchedCustomer?.mobile ??
            controller.customerMobileController.text.trim(),
        customerCity:
            matchedCustomer?.city ??
            controller.customerCityController.text.trim(),
        customerCode: matchedCustomer?.customerId ?? '-',
        invoiceNo: createdBill.invoiceNo,
        invoiceDate: displayDate,
        billedBy: authProv.currentUser?.name ?? '',
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BillSuccessScreen(
            billType: isPakka
                ? 'Pakka Bill ( GST invoice )'
                : 'Kaccha Bill ( Cash Memo )',
            invoiceNo: createdBill.invoiceNo,
            date: displayDate,
            customer: custFinalName,
            amount: createdBill.totalAmount > 0
                ? (createdBill.totalAmount == createdBill.totalAmount.roundToDouble()
                    ? createdBill.totalAmount.toStringAsFixed(0)
                    : createdBill.totalAmount.toStringAsFixed(2))
                : (amountPaid == amountPaid.roundToDouble()
                    ? amountPaid.toStringAsFixed(0)
                    : amountPaid.toStringAsFixed(2)),
            paymentMode: displayPaymentMode,
            pdfData: pdfData,
            billingModel: createdBill,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating bill: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_controller.isAddingNewCustomer) {
            _controller.toggleAddNewCustomer(false);
          } else if (_controller.currentStep > 1) {
            _controller.previousStep();
          } else {
            Navigator.of(context).pop();
          }
        },
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
                    // Top App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          // Back Button
                          Consumer<CreateBillController>(
                            builder: (context, controller, _) {
                              return GestureDetector(
                                onTap: () {
                                  if (controller.isAddingNewCustomer) {
                                    controller.toggleAddNewCustomer(false);
                                  } else if (controller.currentStep > 1) {
                                    controller.previousStep();
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
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
                              );
                            },
                          ),
                          const SizedBox(width: 12),

                          // Title
                          Expanded(
                            child: Center(
                              child: Consumer<CreateBillController>(
                                builder: (context, controller, _) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return Text(
                                    controller.currentDraftId != null
                                        ? l10n.draftBill
                                        : l10n.createBill,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Right Action (Delete Draft button if loaded draft, else spacing)
                          Consumer<CreateBillController>(
                            builder: (context, controller, _) {
                              if (controller.currentDraftId != null) {
                                return GestureDetector(
                                  onTap: () async {
                                    final l10n = AppLocalizations.of(context)!;
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        title: Text(
                                          l10n.deleteDraft,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                        content: Text(
                                          l10n.deleteDraftConfirm,
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                            child: Text(
                                              l10n.cancel,
                                              style: const TextStyle(
                                                color: AppColors.textSubtitle,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(true),
                                            child: Text(
                                              l10n.delete,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await DraftStorageService().deleteDraft(
                                        controller.currentDraftId!,
                                      );
                                      if (context.mounted) {
                                        try {
                                          context
                                              .read<HomeController>()
                                              .loadPendingDrafts();
                                        } catch (_) {}
                                      }
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(
                                                Icons.delete_sweep_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                l10n.draftDeletedSuccess,
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.22,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.redAccent.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox(width: 44);
                            },
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
                          child: GestureDetector(
                            onTap: () =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            behavior: HitTestBehavior.translucent,
                            child: SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.fromLTRB(
                                16,
                                20,
                                16,
                                isKeyboardOpen ? 32 : 180,
                              ),
                              child: Consumer<CreateBillController>(
                                builder: (context, controller, _) {
                                  final step = controller.currentStep;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Step Indicator
                                      Text(
                                        'Step $step - ${controller.totalSteps}',
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBody,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Render step content
                                      if (step == 1) ...[
                                        _buildStep1Content(controller),
                                      ] else if (step == 2) ...[
                                        Step2ProductSelectionView(
                                          controller: controller,
                                        ),
                                      ] else if (step == 3) ...[
                                        Step3BillSummaryView(
                                          controller: controller,
                                        ),
                                      ] else if (step == 4) ...[
                                        Step4PaymentOptionsView(
                                          controller: controller,
                                        ),
                                      ] else if (step == 5) ...[
                                        Step5InvoicePreviewView(
                                          controller: controller,
                                        ),
                                      ] else ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 40,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Step $step Content',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.textSubtitle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Bottom Fixed Action Bar
              Consumer<CreateBillController>(
                builder: (context, controller, _) {
                  final isAddingCust =
                      controller.currentStep == 1 &&
                      controller.isAddingNewCustomer;
                  if (isKeyboardOpen || isAddingCust) {
                    return const SizedBox.shrink();
                  }

                  final step = controller.currentStep;
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 5, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Summary info row in Step 2
                            if (step == 2) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left: Items & Qty
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${AppLocalizations.of(context)!.items} - ${controller.totalItemsCount}',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBody,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${AppLocalizations.of(context)!.quantity} - ${controller.totalQuantityCount}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Right: Amount & Total
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '₹${controller.totalAmountSum.toStringAsFixed(controller.totalAmountSum == controller.totalAmountSum.roundToDouble() ? 0 : 2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDark,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      Text(
                                        AppLocalizations.of(context)!.totalAmount,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Summary info row in Step 4
                            if (step == 4) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.totalAmount,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textBody,
                                    ),
                                  ),
                                  Text(
                                    '₹${controller.totalAmountSum.toStringAsFixed(controller.totalAmountSum == controller.totalAmountSum.roundToDouble() ? 0 : 2)}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Action Buttons: Step 5 has single full-width button
                            if (step == 5) ...[
                              Consumer<BillingProvider>(
                                builder: (context, billingProv, _) {
                                  final l10n = AppLocalizations.of(context)!;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: billingProv.isCreating
                                          ? null
                                          : () => _submitBill(
                                              context,
                                              controller,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        disabledBackgroundColor: AppColors
                                            .primaryBlue
                                            .withValues(alpha: 0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: billingProv.isCreating
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  l10n.generateBillText,
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                const Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  size: 18,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ] else ...[
                              // Action Buttons Row (Steps 1-4)
                              Row(
                                children: [
                                  // Save Draft Button
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          final l10n = AppLocalizations.of(context)!;
                                          // Auto-add product if selected but not yet added in step 2
                                          if (controller.currentStep == 2 &&
                                              controller.selectedProductId !=
                                                  null) {
                                            controller.addProductToList();
                                          }

                                          final draft = controller
                                              .toDraftModel();
                                          await DraftStorageService().saveDraft(
                                            draft,
                                          );
                                          if (context.mounted) {
                                            try {
                                              context
                                                  .read<HomeController>()
                                                  .loadPendingDrafts();
                                            } catch (_) {}
                                          }

                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.check_circle_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    l10n.invoiceCreatedSuccess,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              backgroundColor: const Color(
                                                0xFF10B981,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: AppColors.primaryBlue,
                                            width: 1.4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.saveDraftText,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Continue Button
                                  Expanded(
                                    child: SizedBox(
                                      height: 48,
                                      child: ElevatedButton(
                                        onPressed: () => _handleContinue(
                                          context,
                                          controller,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.continueText,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1Content(CreateBillController controller) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CARD 1: FIRM & BILL TYPE ---
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
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
              // Select Firm Dropdown
              Consumer<CompanyProvider>(
                builder: (context, companyProv, _) {
                  final firmList = companyProv.companies
                      .map((c) => c.name)
                      .where((n) => n.trim().isNotEmpty)
                      .toSet()
                      .toList();
                  final effectiveFirm =
                      firmList.contains(controller.selectedFirm)
                      ? controller.selectedFirm
                      : null;

                  return CustomDropdownField(
                    label: l10n.selectFirm,
                    hintText: l10n.selectFirm,
                    value: effectiveFirm,
                    items: firmList,
                    onChanged: (val) {
                      final match = companyProv.companies
                          .where((c) => c.name == val)
                          .toList();
                      final compId = match.isNotEmpty ? match.first.id : null;
                      controller.selectFirm(val, companyId: compId);
                      companyProv.selectCompanyByName(val);
                      if (compId != null) {
                        context.read<SizeMasterProvider>().fetchAll(
                          companyId: compId,
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 18),

              // Choose bill type subtitle
              Text(
                l10n.chooseBillType,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 14),

              // Pakka Bill & Kaccha Bill Options
              Consumer<AuthProvider>(
                builder: (context, authProv, _) {
                  final canAccessKaccha =
                      authProv.currentUser?.canAccessKaccha ?? true;

                  // If user cannot access Kaccha Bill but it is selected, fallback to Pakka Bill
                  if (!canAccessKaccha &&
                      controller.selectedBillType ==
                          CreateBillType.kacchaBill) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      controller.selectBillType(CreateBillType.pakkaBill);
                    });
                  }

                  return Column(
                    children: [
                      BillTypeSelectorCard(
                        title: l10n.pakkaBill,
                        subtitle: l10n.gstInvoice,
                        titleColor: const Color(0xFF0284C7),
                        imagePath: 'assets/images/invoice_2.png',
                        isSelected:
                            controller.selectedBillType ==
                            CreateBillType.pakkaBill,
                        onTap: () =>
                            controller.selectBillType(CreateBillType.pakkaBill),
                      ),
                      BillTypeSelectorCard(
                        title: l10n.kacchaBill,
                        subtitle: l10n.cashMemo,
                        titleColor: const Color(0xFF16A34A),
                        imagePath: 'assets/images/invoice_2.png',
                        isEnabled: canAccessKaccha,
                        isSelected:
                            controller.selectedBillType ==
                            CreateBillType.kacchaBill,
                        onTap: () {
                          if (canAccessKaccha) {
                            controller.selectBillType(
                              CreateBillType.kacchaBill,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- CARD 2: CUSTOMER ---
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: controller.isAddingNewCustomer
              ? AddCustomerForm(controller: controller)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Type Segmented Switch
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setCustomerType(BillCustomerType.registered),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: controller.customerType == BillCustomerType.registered
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: controller.customerType == BillCustomerType.registered
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: controller.customerType == BillCustomerType.registered
                                          ? AppColors.primaryBlue
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.registered,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: controller.customerType == BillCustomerType.registered
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: controller.customerType == BillCustomerType.registered
                                            ? AppColors.primaryBlue
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.setCustomerType(BillCustomerType.walkIn),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: controller.customerType == BillCustomerType.walkIn
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: controller.customerType == BillCustomerType.walkIn
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_walk,
                                      size: 16,
                                      color: controller.customerType == BillCustomerType.walkIn
                                          ? AppColors.primaryBlue
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.walkIn,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: controller.customerType == BillCustomerType.walkIn
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: controller.customerType == BillCustomerType.walkIn
                                            ? AppColors.primaryBlue
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (controller.customerType == BillCustomerType.registered) ...[
                      // Select Customer Dropdown
                      Consumer<CustomerProvider>(
                        builder: (context, customerProv, _) {
                          final companyCustomers = customerProv
                              .getCustomersForCompany(
                                companyId: controller.selectedCompanyId,
                                companyName: controller.selectedFirm,
                              );

                          final customerList = companyCustomers
                              .map((c) => c.name)
                              .where((n) => n.trim().isNotEmpty)
                              .toSet()
                              .toList();

                          final currentValue =
                              customerList.contains(controller.selectedCustomer)
                              ? controller.selectedCustomer
                              : null;

                          return CustomDropdownField(
                            label: l10n.selectCustomer,
                            hintText: customerList.isEmpty
                                ? (controller.selectedFirm != null
                                      ? l10n.noCustomersFoundFirm
                                      : l10n.selectFirmFirst)
                                : l10n.selectCustomer,
                            value: currentValue,
                            items: customerList,
                            onChanged: controller.selectCustomer,
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // + Add New Customer Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => controller.toggleAddNewCustomer(true),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                l10n.addNewCustomer,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Walk-in Name Text Field
                      CustomTextField(
                        label: l10n.walkInName,
                        hintText: l10n.enterWalkInName,
                        controller: controller.walkInNameController,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
