import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../company/providers/company_provider.dart';
import '../../create_bill/create_bill_ui/create_bill_screen.dart';
import '../../create_bill/providers/billing_provider.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../../notification/notification_ui/notification_screen.dart';
import '../../notification/providers/notification_provider.dart';
import '../../payment_collection/payment_collection_ui/payment_collection_screen.dart';
import '../../sales_return/sales_return_ui/sales_return_screen.dart';
import '../controllers/home_controller.dart';
import '../models/bill_model.dart';
import 'widgets/available_stock_carousel.dart';
import 'widgets/breathing_dot.dart';
import 'widgets/company_switcher_sheet.dart';
import 'widgets/draft_bills_sheet.dart';
import 'widgets/home_header.dart';
import 'widgets/metric_card.dart';
import 'widgets/pending_bills_card.dart';
import 'widgets/recent_bill_card.dart';
import 'widgets/record_payment_sheet.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSales;
  final VoidCallback? onNavigateToReturns;
  final VoidCallback? onCreateInvoice;

  const HomeScreen({
    super.key,
    this.onNavigateToSales,
    this.onNavigateToReturns,
    this.onCreateInvoice,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HomeController>().loadPendingDrafts();
        _loadDashboardData();
      }
    });
  }

  Future<void> _loadDashboardData([String? companyId]) async {
    final billingProvider = context.read<BillingProvider>();
    final homeController = context.read<HomeController>();
    final companyProv = context.read<CompanyProvider>();

    // Fetch companies to get the updated billingMetrics from backend
    await companyProv.fetchCompanies();
    if (companyId != null) {
      companyProv.selectCompanyById(companyId);
    }

    final selectedCompany = companyProv.selectedCompany;
    homeController.setMetricsFromCompany(selectedCompany?.billingMetrics);
    homeController.loadAvailableProducts([]);
    homeController.loadBillsData([]);

    final resolvedCompanyId = selectedCompany?.id;

    // Fetch bills, available stock, and notifications in parallel
    await Future.wait([
      billingProvider
          .fetchTodayBillModels(companyId: resolvedCompanyId)
          .then((_) {
        if (mounted) {
          homeController.loadBillsData(billingProvider.todayBillModels);
        }
      }),
      billingProvider
          .fetchAvailableProducts(companyId: resolvedCompanyId)
          .then((_) {
        if (mounted) {
          homeController
              .loadAvailableProducts(billingProvider.availableProducts);
        }
      }),
      if (mounted)
        context
            .read<NotificationProvider>()
            .fetchNotifications(companyId: resolvedCompanyId),
    ]);
  }

  String _formatSalesAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toStringAsFixed(0)}';
    } else {
      final str = amount.toStringAsFixed(2);
      if (str.endsWith('.00')) {
        return '₹${amount.toStringAsFixed(0)}';
      } else if (str.endsWith('0')) {
        return '₹${str.substring(0, str.length - 1)}';
      }
      return '₹$str';
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat('#,##,###');

    return Scaffold(
      backgroundColor: AppColors.spaceDarkBlue,
      body: Stack(
        children: [
          // 1. Starry Top Sky Background
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: StarryHeaderBackground(height: 340),
          ),

          // 2. Scrollable Body with Pull-to-Refresh
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: AppColors.primaryBlue,
              backgroundColor: Colors.white,
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Top Header (Greeting + Quick Actions)
                    HomeHeader(
                      onNotificationTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        );
                      },
                      onCreateInvoice: widget.onCreateInvoice ??
                          () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const CreateBillScreen(),
                              ),
                            );
                          },
                      onSalesRegister: widget.onNavigateToSales,
                      onPaymentCollection: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PaymentCollectionScreen(),
                          ),
                        );
                      },
                      onSalesReturn: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SalesReturnScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // White Rounded Body Container
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F7FF),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28.0),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
                      child: Consumer<HomeController>(
                        builder: (context, controller, _) {
                          final billingProv = context.watch<BillingProvider>();
                          final l10n = AppLocalizations.of(context);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Metric Cards Row 1: Invoices & Sales
                              Row(
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      icon: Image.asset(
                                        'assets/images/invoice_1.png',
                                        width: 24,
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.receipt_long_rounded,
                                          color: Color(0xFF0284C7),
                                          size: 22,
                                        ),
                                      ),
                                      title: l10n?.totalInvoices ?? 'Total Invoices',
                                      value: '${controller.totalInvoices}',
                                      percentageChange: 'Total',
                                      isPositive: true,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: MetricCard(
                                      icon: Image.asset(
                                        'assets/images/sales_1.png',
                                        width: 24,
                                        height: 24,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.bar_chart_rounded,
                                          color: Color(0xFF0284C7),
                                          size: 24,
                                        ),
                                      ),
                                      title: l10n?.totalSales ?? 'Total Sales',
                                      value: _formatSalesAmount(
                                          controller.totalSales),
                                      percentageChange: 'Total',
                                      isPositive: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Metric Cards Row 2: Stock Units & Low Stock Status
                              Row(
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      icon: Image.asset(
                                        'assets/images/packages.png',
                                        width: 22,
                                        height: 22,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.inventory_2_rounded,
                                          color: Color(0xFF0284C7),
                                          size: 24,
                                        ),
                                      ),
                                      title: l10n?.totalStock ?? 'Total Stock',
                                      value: controller.totalAvailableStock > 0
                                          ? numberFormat.format(controller.totalAvailableStock)
                                          : '${controller.totalAvailableStock}',
                                      percentageChange: l10n?.units ?? 'Units',
                                      isPositive: true,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: MetricCard(
                                      icon: controller.lowStockCount > 0
                                          ? Image.asset(
                                              'assets/images/danger_sign.png',
                                              width: 22,
                                              height: 22,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (context, error, stackTrace) =>
                                                      Image.asset(
                                                'assets/images/out-of-stock.png',
                                                width: 22,
                                                height: 22,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.check_circle_outline_rounded,
                                              color: Color(0xFF16A34A),
                                              size: 24,
                                            ),
                                      title: l10n?.lowStockAlert ?? 'Low Stock Alert',
                                      value: '${controller.lowStockCount}',
                                      percentageChange:
                                          controller.lowStockCount > 0
                                              ? 'Alert'
                                              : 'Healthy',
                                      isPositive: controller.lowStockCount == 0,
                                      isAlert: controller.lowStockCount > 0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // 2. Pending Bills Banner Card
                              PendingBillsCard(
                                count: controller.pendingDraftsCount,
                                onContinue: () async {
                                  if (controller.pendingDraftsCount > 1) {
                                    DraftBillsSheet.show(
                                      context,
                                      controller,
                                    );
                                  } else if (controller.pendingDraftsCount ==
                                      1) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CreateBillScreen(
                                          initialDraft:
                                              controller.drafts.first,
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<HomeController>()
                                          .loadPendingDrafts();
                                    }
                                  } else {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateBillScreen(),
                                      ),
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<HomeController>()
                                          .loadPendingDrafts();
                                    }
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // 3. Available Stock Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        l10n?.availableStock ?? 'Available Stock',
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBody,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      if (controller.availableProducts.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${controller.availableProducts.length}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0284C7),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const BreathingDot(
                                        color: Color(0xFFEF4444),
                                        size: 4.0,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n?.liveInventory ?? 'Live Inventory',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // 4. Available Stock List / Status
                              if (billingProv.isLoadingProducts)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryBlue,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              else if (controller.availableProducts.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 22,
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/images/out-of-stock.png',
                                        width: 36,
                                        height: 36,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.inventory_2_outlined,
                                          size: 32,
                                          color: AppColors.textSubtitle,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n?.noStockItemsFound ?? 'No stock items found',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: AppColors.textSubtitle,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                AvailableStockCarousel(
                                  products: controller.availableProducts,
                                ),
                              const SizedBox(height: 26),

                              // 5. Recent Bills Header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        l10n?.recentBills ?? 'Recent Bills Generated',
                                        style: const TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textBody,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Color(0xFF16A34A),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              l10n?.today ?? 'Today',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: widget.onNavigateToSales,
                                    child: Text(
                                      l10n?.viewAll ?? 'See All',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Company Filter / Switcher Bar
                              Consumer<CompanyProvider>(
                                builder: (context, compProv, _) {
                                  final activeCompany = compProv.selectedCompany;
                                  final companyName = activeCompany?.name.isNotEmpty == true
                                      ? activeCompany!.name
                                      : 'Select Company';

                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        CompanySwitcherSheet.show(
                                          context,
                                          onCompanySelected: (company) {
                                            _loadDashboardData(company.id);
                                          },
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.business_rounded,
                                              size: 15,
                                              color: AppColors.primaryBlue,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Company: ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textLabel,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                companyName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 3,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Change',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.primaryBlue,
                                                    ),
                                                  ),
                                                  SizedBox(width: 3),
                                                  Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    size: 14,
                                                    color: AppColors.primaryBlue,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),

                              // 6. Recent Bills List
                              if (billingProv.isLoadingTodayBills)
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.primaryBlue,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                )
                              else if (controller.recentBills.isEmpty)
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(vertical: 30),
                                  child: Center(
                                    child: Text(
                                      'No bills generated yet',
                                      style: TextStyle(
                                        fontSize: 14,
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
                                  itemCount:
                                      controller.recentBills.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final bill =
                                        controller.recentBills[index];
                                    return RecentBillCard(
                                      bill: bill,
                                      onTap: () async {
                                        // Only show payment sheet for bills with due amount
                                        if (bill.dueAmount > 0 &&
                                            bill.status !=
                                                BillStatus.paid) {
                                          final companyProv =
                                              context.read<
                                                  CompanyProvider>();
                                          final companyId = companyProv
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
                                              mounted) {
                                            _loadDashboardData(
                                                companyId.isNotEmpty
                                                    ? companyId
                                                    : null);
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
