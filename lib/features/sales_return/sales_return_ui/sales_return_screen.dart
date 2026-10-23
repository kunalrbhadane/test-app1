import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rk_plast/features/home/models/bill_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../create_bill/providers/billing_provider.dart';
import '../../customer/providers/customer_provider.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/controllers/home_controller.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../controllers/sales_return_controller.dart';
import 'widgets/step2_sales_return_view.dart';
import 'widgets/step3_sales_return_summary_view.dart';

class SalesReturnScreen extends StatefulWidget {
  const SalesReturnScreen({super.key});

  @override
  State<SalesReturnScreen> createState() => _SalesReturnScreenState();
}

class _SalesReturnScreenState extends State<SalesReturnScreen> {
  late final SalesReturnController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SalesReturnController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CompanyProvider>().fetchCompanies();
        context.read<CustomerProvider>().fetchCustomers();
        final billingProv = context.read<BillingProvider>();
        // Fetch registered customer bills
        billingProv.fetchBillModels().then((_) {
          if (mounted) {
            _controller.setAvailableBills(billingProv.todayBillModels);
          }
        });
        // Fetch walk-in customer bills
        billingProv.fetchWalkInBills().then((_) {
          if (mounted) {
            _controller.setWalkInBills(billingProv.walkInBillModels);
          }
        });
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
    final l10n = AppLocalizations.of(context);
    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                          onTap: () {
                            if (_controller.currentStep == 3) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => DashboardScreen(
                                    initialIndex: 3,
                                  ),
                                ),
                                (route) => false,
                              );
                            } else if (_controller.currentStep > 1) {
                              _controller.previousStep();
                            } else {
                              Navigator.maybePop(context);
                            }
                          },
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
                                l10n?.salesReturns ?? 'Sales Return',
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
                            child: Consumer<SalesReturnController>(
                              builder: (context, controller, _) {
                                final step = controller.currentStep;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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

                                    // Step Content
                                    if (step == 1) ...[
                                      _buildStep1Content(controller),
                                    ] else if (step == 2) ...[
                                      Step2SalesReturnView(
                                        controller: controller,
                                      ),
                                    ] else if (step == 3) ...[
                                      Step3SalesReturnSummaryView(
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

            // 3. Bottom Fixed Action Bar (hidden while typing)
            if (!isKeyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
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
                    child: Consumer<SalesReturnController>(
                      builder: (context, controller, _) {
                        final step = controller.currentStep;

                        // --- STEP 3: DONE / GO TO RETURNS LOG ---
                        if (step == 3) {
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => DashboardScreen(
                                      initialIndex: 3,
                                    ),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 19,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n?.done ?? 'Done / Go to Returns Log',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // --- STEP 2: SUBMIT RETURN (HITS API) ---
                        if (step == 2) {
                          return SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                                  onPressed: controller.isSubmitting
                                      ? null
                                      : () async {
                                          if (!controller.canProceedToStep3()) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please specify at least 1 item with return quantity > 0',
                                                ),
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            return;
                                          }

                                          final reasonText = controller
                                                  .reasonController.text
                                                  .trim()
                                                  .isNotEmpty
                                              ? controller
                                                  .reasonController.text
                                                  .trim()
                                              : 'Damage Products';
                                          final returnLines = controller
                                              .returnItems
                                              .where(
                                                (item) =>
                                                    item.returnQty > 0 &&
                                                    item.productId.isNotEmpty,
                                              )
                                              .map(
                                                (item) => {
                                                  'product': item.productId,
                                                  'qty': item.returnQty,
                                                  'reasone': reasonText,
                                                },
                                              )
                                              .toList();

                                          if (returnLines.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please specify at least 1 item quantity to return',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            return;
                                          }

                                          final companyId = controller
                                                  .selectedCompanyId ??
                                              '';
                                          final invoiceNo = controller
                                                  .selectedBillModel
                                                  ?.invoiceNumber ??
                                              controller.selectedInvoice ??
                                              '';

                                          if (invoiceNo.isEmpty) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Please select a valid invoice',
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                            return;
                                          }

                                          controller.setSubmitting(true);
                                          try {
                                            final billingProv = context
                                                .read<BillingProvider>();
                                            final res = await billingProv
                                                .returnProducts(
                                              companyId: companyId,
                                              invoiceNo: invoiceNo,
                                              lines: returnLines,
                                            );

                                            if (context.mounted) {
                                              // Store response data in controller
                                              controller.setReturnResponse(res);

                                              // Update home dashboard bills
                                              context
                                                  .read<HomeController>()
                                                  .loadBillsData(
                                                    billingProv.todayBillModels,
                                                  );

                                              final message = res['message']
                                                      ?.toString() ??
                                                  'Products returned successfully';
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(message),
                                                  backgroundColor:
                                                      const Color(0xFF16A34A),
                                                  duration:
                                                      const Duration(seconds: 3),
                                                ),
                                              );

                                              // Navigate to Step 3 to show backend response
                                              controller.nextStep();
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              final msg = e
                                                  .toString()
                                                  .replaceFirst(
                                                    'Exception: ',
                                                    '',
                                                  );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(msg),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  duration:
                                                      const Duration(seconds: 4),
                                                ),
                                              );
                                            }
                                          } finally {
                                            controller.setSubmitting(false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: controller.isSubmitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Submit Return',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 17,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            }

                        // --- STEP 1: CONTINUE BUTTON ---
                        return SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.selectedFirm == null ||
                                  controller.selectedFirm!.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select Firm first'),
                                    backgroundColor: Colors.orangeAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              if (controller.customerType ==
                                  SalesReturnCustomerType.registered) {
                                if (controller.selectedCustomer == null ||
                                    controller.selectedCustomer!.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select Customer'),
                                      backgroundColor: Colors.orangeAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                              } else {
                                if (controller.selectedWalkInName == null ||
                                    controller.selectedWalkInName!.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please select Walk-in Customer'),
                                      backgroundColor: Colors.orangeAccent,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }
                              }

                              if (controller.selectedInvoice == null ||
                                  controller.selectedInvoice!.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select Invoice'),
                                    backgroundColor: Colors.orangeAccent,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              controller.nextStep();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n?.continueText ?? 'Continue',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 17,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Content(SalesReturnController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CARD 1: SELECT FIRM ---
        Container(
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
                    label: 'Select Firm',
                    hintText: 'Select Firm',
                    value: effectiveFirm,
                    items: firmList,
                    onChanged: (val) {
                      final match = companyProv.companies
                          .where((c) => c.name == val)
                          .toList();
                      final compId =
                          match.isNotEmpty ? match.first.id : null;
                      controller.selectFirm(val, companyId: compId);
                      companyProv.selectCompanyByName(val);

                      if (compId != null && compId.isNotEmpty) {
                        final billingProv = context.read<BillingProvider>();
                        controller.setLoadingWalkIn(true);
                        billingProv.fetchWalkInBills(companyId: compId).then((_) {
                          if (mounted) {
                            controller.setWalkInBills(billingProv.walkInBillModels);
                          }
                        });
                        billingProv.fetchBillModels(companyId: compId).then((_) {
                          if (mounted) {
                            controller.setAvailableBills(billingProv.todayBillModels);
                          }
                        });
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // --- CARD 2: CUSTOMER TYPE TOGGLE, CUSTOMER/WALK-IN & INVOICE ---
        Container(
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
              // Customer Type Toggle
              const Text(
                'Customer Type',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.setCustomerType(
                            SalesReturnCustomerType.registered),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: controller.customerType ==
                                    SalesReturnCustomerType.registered
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline_rounded,
                                size: 16,
                                color: controller.customerType ==
                                        SalesReturnCustomerType.registered
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Registered',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: controller.customerType ==
                                          SalesReturnCustomerType.registered
                                      ? Colors.white
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
                        onTap: () {
                          if (controller.selectedFirm == null ||
                              controller.selectedFirm!.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select Firm first'),
                                backgroundColor: Colors.orangeAccent,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          controller.setCustomerType(
                              SalesReturnCustomerType.walkIn);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: controller.customerType ==
                                    SalesReturnCustomerType.walkIn
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.directions_walk_rounded,
                                size: 16,
                                color: controller.customerType ==
                                        SalesReturnCustomerType.walkIn
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Walk-in',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: controller.customerType ==
                                          SalesReturnCustomerType.walkIn
                                      ? Colors.white
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
              const SizedBox(height: 16),

              // --- REGISTERED CUSTOMER DROPDOWN ---
              if (controller.customerType ==
                  SalesReturnCustomerType.registered) ...[
                const Text(
                  'Customer*',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Consumer<CustomerProvider>(
                  builder: (context, customerProv, _) {
                    final companyCustomers =
                        customerProv.getCustomersForCompany(
                      companyId: controller.selectedCompanyId,
                      companyName: controller.selectedFirm,
                    );

                    final list = companyCustomers
                        .map((c) => c.name)
                        .where((n) => n.trim().isNotEmpty)
                        .toSet()
                        .toList();

                    final currentValue =
                        list.contains(controller.selectedCustomer)
                            ? controller.selectedCustomer
                            : null;

                    return _buildBlueDropdownField(
                      value: currentValue,
                      hint: list.isEmpty
                          ? (controller.selectedFirm != null
                              ? 'No customers found'
                              : 'Select Firm first')
                          : 'Select Customer',
                      items: list,
                      onChanged: controller.selectCustomer,
                      onTapWhenEmpty: () {
                        if (controller.selectedFirm == null ||
                            controller.selectedFirm!.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select Firm first'),
                              backgroundColor: Colors.orangeAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],

              // --- WALK-IN CUSTOMER DROPDOWN ---
              if (controller.customerType ==
                  SalesReturnCustomerType.walkIn) ...[
                const Text(
                  'Walk-in Customer*',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    if (controller.isLoadingWalkIn) {
                      return Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Loading walk-in customers...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final walkInNames = controller.getWalkInNames(
                      companyId: controller.selectedCompanyId,
                      companyName: controller.selectedFirm,
                    );
                    final currentValue =
                        walkInNames.contains(controller.selectedWalkInName)
                            ? controller.selectedWalkInName
                            : null;

                    return _buildBlueDropdownField(
                      value: currentValue,
                      hint: walkInNames.isEmpty
                          ? (controller.selectedFirm != null
                              ? 'No walk-in invoices found'
                              : 'Select Firm first')
                          : 'Select Walk-in Customer',
                      items: walkInNames,
                      onChanged: controller.selectWalkInName,
                      onTapWhenEmpty: () {
                        if (controller.selectedFirm == null ||
                            controller.selectedFirm!.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select Firm first'),
                              backgroundColor: Colors.orangeAccent,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Invoice Dropdown
              const Text(
                'Invoice*',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Consumer<BillingProvider>(
                builder: (context, billingProv, _) {
                  final bool isWalkIn = controller.customerType ==
                      SalesReturnCustomerType.walkIn;

                  final invoices = isWalkIn
                      ? controller.getWalkInInvoices(
                          companyId: controller.selectedCompanyId,
                          companyName: controller.selectedFirm,
                          walkInName: controller.selectedWalkInName,
                        )
                      : controller.getAvailableInvoices(
                          companyId: controller.selectedCompanyId,
                          companyName: controller.selectedFirm,
                          customerName: controller.selectedCustomer,
                        );

                  final effectiveInvoice =
                      invoices.contains(controller.selectedInvoice)
                          ? controller.selectedInvoice
                          : null;

                  final hasSelection = isWalkIn
                      ? controller.selectedWalkInName != null
                      : controller.selectedCustomer != null;

                  return _buildBlueDropdownField(
                    value: effectiveInvoice,
                    hint: invoices.isEmpty
                        ? (hasSelection
                            ? 'No invoices found'
                            : (isWalkIn
                                ? 'Select Walk-in Customer first'
                                : 'Select Customer first'))
                        : 'Select Invoice',
                    items: invoices,
                    onChanged: controller.selectInvoice,
                    onTapWhenEmpty: () {
                      if (controller.selectedFirm == null ||
                          controller.selectedFirm!.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select Firm first'),
                            backgroundColor: Colors.orangeAccent,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else if (!hasSelection) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isWalkIn
                                  ? 'Please select Walk-in Customer first'
                                  : 'Please select Customer first',
                            ),
                            backgroundColor: Colors.orangeAccent,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // --- CARD 3: SELECTED INVOICE PREVIEW ---
        if (controller.selectedBillModel != null) ...[
          const SizedBox(height: 16),
          _buildSelectedInvoicePreviewCard(controller.selectedBillModel!),
        ],
      ],
    );
  }

  Widget _buildSelectedInvoicePreviewCard(BillModel bill) {
    final bool isGST = bill.type == BillType.gstInvoice;
    final Color typeBg =
        isGST ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9);
    final Color typeColor =
        isGST ? const Color(0xFF2563EB) : const Color(0xFF64748B);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 16,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Selected Invoice Details',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: _getStatusBg(bill.status),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  bill.statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: _getStatusTextColor(bill.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Invoice # & Date / Mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    bill.invoiceNumber,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bill.typeLabel,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                bill.date,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Customer Info & Firm
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            bill.partyName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (bill.isWalkIn) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Walk-in',
                              style: TextStyle(
                                fontSize: 9.5,
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
                        if (bill.companyName != null && bill.companyName!.isNotEmpty) ...[
                          Text(
                            bill.companyName!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (bill.customerCity != null && bill.customerCity!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bill.customerCity!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
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
              if (bill.createdByName != null && bill.createdByName!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Billed By',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Text(
                      bill.createdByName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Financial Summary Grid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFF1F5F9),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPreviewMiniMetric('Sub Total', '₹${bill.subTotal.toStringAsFixed(0)}'),
                if (bill.gstAmount > 0)
                  _buildPreviewMiniMetric('GST', '₹${bill.gstAmount.toStringAsFixed(1)}'),
                _buildPreviewMiniMetric('Total', '₹${bill.amount.toStringAsFixed(0)}'),
                _buildPreviewMiniMetric('Paid', '₹${bill.amountPaid.toStringAsFixed(0)}', valueColor: const Color(0xFF16A34A)),
                _buildPreviewMiniMetric(
                  'Due',
                  '₹${bill.dueAmount.toStringAsFixed(0)}',
                  valueColor: bill.dueAmount > 0 ? const Color(0xFFE11D48) : const Color(0xFF16A34A),
                ),
                _buildPreviewMiniMetric('Mode', bill.formattedPaymentMode),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Products in Bill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Products (${bill.lines.length})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                'Total Qty: ${bill.totalQty > 0 ? bill.totalQty : bill.lines.fold(0, (s, l) => s + l.qty)} NOS',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...bill.lines.map((line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  Text(
                    '${line.qty} pcs @ ₹${line.rate.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (line.returnedQty > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${line.returnedQty} rtn',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPreviewMiniMetric(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
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

  Widget _buildBlueDropdownField({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    VoidCallback? onTapWhenEmpty,
  }) {
    final uniqueItems = items.toSet().toList();
    final effectiveValue =
        (value != null && uniqueItems.contains(value)) ? value : null;

    final child = Container(
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
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            );
          }).toList(),
          onChanged: uniqueItems.isEmpty ? null : onChanged,
        ),
      ),
    );

    if (uniqueItems.isEmpty && onTapWhenEmpty != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTapWhenEmpty,
        child: IgnorePointer(child: child),
      );
    }

    return child;
  }
}
