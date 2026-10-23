import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_error_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../create_bill/providers/billing_provider.dart';
import '../../home/home_ui/widgets/recent_bill_card.dart';
import '../../home/home_ui/widgets/record_payment_sheet.dart';
import '../../home/models/bill_model.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../controllers/sales_controller.dart';
import 'widgets/export_sales_sheet.dart';
import 'widgets/sales_filter_tabs.dart';
import 'widgets/sales_header.dart';

class SalesScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SalesScreen({
    super.key,
    this.onBack,
  });

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late final SalesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SalesController();
    _loadBills();
  }

  void _loadBills() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final companyId = context.read<CompanyProvider>().selectedCompany?.id;
      final billingProvider = context.read<BillingProvider>();
      billingProvider.fetchBillModels(companyId: companyId).then((_) {
        if (mounted) {
          _controller.setBills(billingProvider.billModels);
        }
      });
    });
  }

  Future<void> _refreshBills() async {
    final companyId = context.read<CompanyProvider>().selectedCompany?.id;
    final billingProvider = context.read<BillingProvider>();
    await billingProvider.fetchBillModels(companyId: companyId);
    if (mounted) {
      _controller.setBills(billingProvider.billModels);
    }
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
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.spaceDarkBlue,
        body: Stack(
          children: [
            // 1. Starry Sky Header Background
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
                  SalesHeader(
                    onBackTap: widget.onBack,
                    onExportTap: () {
                      final companyProv = context.read<CompanyProvider>();
                      final billsToExport = _controller.filteredBills.isNotEmpty
                          ? _controller.filteredBills
                          : _controller.allBills;

                      ExportSalesSheet.show(
                        context,
                        bills: billsToExport,
                        company: companyProv.selectedCompany,
                        selectedFilter: _controller.selectedFilter,
                      );
                    },
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
                        child: Consumer<BillingProvider>(
                          builder: (context, billingProvider, _) {
                            // Loading state
                            if (billingProvider.isLoadingBills) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryBlue,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              );
                            }

                            // Error state
                            if (billingProvider.billsError != null) {
                              final errorMessage = ApiErrorHandler.getErrorMessage(
                                billingProvider.billsError!,
                              );
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 40,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE2E2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFFCA5A5),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.wifi_off_rounded,
                                            color: Color(0xFFDC2626),
                                            size: 36,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        l10n.unableToLoadSales,
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        errorMessage,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: Color(0xFF64748B),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton.icon(
                                        onPressed: _refreshBills,
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                        ),
                                        label: Text(l10n.tryAgain),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryBlue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Data loaded — show bills
                            return RefreshIndicator(
                              onRefresh: _refreshBills,
                              color: AppColors.primaryBlue,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.fromLTRB(
                                    16, 20, 16, 140),
                                child: Consumer<SalesController>(
                                  builder: (context, controller, _) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 1. Search Bar & Filter Button Row
                                        Row(
                                          children: [
                                            // Search Input Field
                                            Expanded(
                                              child: Container(
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0),
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: TextField(
                                                  controller: controller
                                                      .searchController,
                                                  onChanged: controller
                                                      .onSearchChanged,
                                                  autocorrect: false,
                                                  enableSuggestions: false,
                                                  spellCheckConfiguration:
                                                      const SpellCheckConfiguration
                                                          .disabled(),
                                                  style: const TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textBody,
                                                    decoration:
                                                        TextDecoration.none,
                                                  ),
                                                  cursorColor:
                                                      AppColors.primaryBlue,
                                                  decoration:
                                                      InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                    enabledBorder:
                                                        InputBorder.none,
                                                    focusedBorder:
                                                        InputBorder.none,
                                                    hintText: l10n.search,
                                                    hintStyle: const TextStyle(
                                                      fontSize: 14.5,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          Color(0xFF94A3B8),
                                                      decoration:
                                                          TextDecoration.none,
                                                    ),
                                                    prefixIcon: const Icon(
                                                      Icons.search_rounded,
                                                      color:
                                                          Color(0xFF94A3B8),
                                                      size: 22,
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),

                                            // Filter Button (Blue Square)
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () {},
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .primaryBlue
                                                            .withValues(
                                                                alpha: 0.3),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                            0, 3),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.tune_rounded,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),

                                        // 2. Segmented Filter Tabs (All / Pakka Bill / Kaccha Bill)
                                        SalesFilterTabs(
                                          selectedFilter:
                                              controller.selectedFilter,
                                          options: controller.filterOptions,
                                          onSelected:
                                              controller.onFilterChanged,
                                        ),
                                        const SizedBox(height: 16),

                                        // 3. Filtered Bills List
                                        if (controller.filteredBills.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 40.0),
                                            child: Center(
                                              child: Text(
                                                l10n.noSalesBillsFound,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  color:
                                                      AppColors.textSubtitle,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.zero,
                                            itemCount: controller
                                                .filteredBills.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 12),
                                            itemBuilder: (context, index) {
                                              final bill = controller
                                                  .filteredBills[index];
                                              return RecentBillCard(
                                                bill: bill,
                                                onTap: () async {
                                                  if (bill.dueAmount > 0 &&
                                                      bill.status !=
                                                          BillStatus.paid) {
                                                    final companyProv =
                                                        context.read<
                                                            CompanyProvider>();
                                                    final companyId =
                                                        companyProv
                                                                .selectedCompany
                                                                ?.id ??
                                                            '';
                                                    final result =
                                                        await RecordPaymentSheet
                                                            .show(
                                                      context,
                                                      bill: bill,
                                                      companyId: companyId,
                                                    );
                                                    if (result == true &&
                                                        context.mounted) {
                                                      context
                                                          .read<
                                                              BillingProvider>()
                                                          .fetchBillModels(
                                                              companyId:
                                                                  companyId);
                                                    }
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                      ],
                                    );
                                  },
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
          ],
        ),
      ),
    );
  }
}
