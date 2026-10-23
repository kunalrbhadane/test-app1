import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../create_bill/providers/billing_provider.dart';
import '../../home/models/bill_model.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../../sales/sales_ui/widgets/export_sales_sheet.dart';
import '../../sales/sales_ui/widgets/sales_filter_tabs.dart';
import '../../sales_return/sales_return_ui/sales_return_screen.dart';
import '../controllers/returns_controller.dart';
import 'widgets/return_item_card.dart';

class ReturnsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ReturnsScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  late final ReturnsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ReturnsController();
    _loadBills();
  }

  void _loadBills() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final billingProvider = context.read<BillingProvider>();
      billingProvider.fetchBillModels().then((_) {
        if (mounted) {
          _controller.setBills(billingProvider.billModels);
        }
      });
    });
  }

  Future<void> _refreshBills() async {
    final billingProvider = context.read<BillingProvider>();
    await billingProvider.fetchBillModels();
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
            // 1. Starry Sky Top Background
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: StarryHeaderBackground(height: 200),
            ),

            // 2. Main Content Body
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: widget.onBack ?? () => Navigator.maybePop(context),
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

                        // Title
                        Text(
                          l10n.salesReturns,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),

                        // Right Action Button
                        GestureDetector(
                          onTap: () {
                            final companyProv = context.read<CompanyProvider>();
                            final returnBills = _controller.filteredReturns
                                .map((r) => r.billModel)
                                .whereType<BillModel>()
                                .toList();

                            ExportSalesSheet.show(
                              context,
                              bills: returnBills,
                              company: companyProv.selectedCompany,
                              selectedFilter: 'Returns (${_controller.selectedFilter})',
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.login_rounded,
                                color: Color(0xFF0062E0),
                                size: 22,
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
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        color: Color(0xFFEF4444),
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        billingProvider.billsError!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSubtitle,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextButton(
                                        onPressed: _refreshBills,
                                        child: Text(l10n.retry),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // Data loaded — show sales returns
                            return RefreshIndicator(
                              onRefresh: _refreshBills,
                              color: AppColors.primaryBlue,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 20, 16, 140),
                                child: Consumer<ReturnsController>(
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
                                                    color:
                                                        const Color(0xFFE2E8F0),
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
                                                      color: Color(0xFF94A3B8),
                                                      decoration:
                                                          TextDecoration.none,
                                                    ),
                                                    prefixIcon: const Icon(
                                                      Icons.search_rounded,
                                                      color: Color(0xFF94A3B8),
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

                                        // 2. Segmented Filter Tabs
                                        SalesFilterTabs(
                                          selectedFilter:
                                              controller.selectedFilter,
                                          options: controller.filterOptions,
                                          onSelected: controller.onFilterChanged,
                                        ),
                                        const SizedBox(height: 18),

                                        // 3. Section Header
                                        Text(
                                          l10n.recentSalesReturns,
                                          style: const TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textBody,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // 4. Returns Items List
                                        if (controller.filteredReturns.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 40.0),
                                            child: Center(
                                              child: Text(
                                                l10n.noSalesReturnsFound,
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  color: AppColors.textSubtitle,
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
                                                .filteredReturns.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(height: 12),
                                            itemBuilder: (context, index) {
                                              return ReturnItemCard(
                                                returnItem: controller
                                                    .filteredReturns[index],
                                                onTap: () {},
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
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 80.0),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SalesReturnScreen(),
                ),
              );
            },
            backgroundColor: AppColors.primaryBlue,
            shape: const CircleBorder(),
            elevation: 4,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
