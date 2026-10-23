import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_bottom_nav_bar.dart';
import '../../l10n/generated/app_localizations.dart';
import '../company/providers/company_provider.dart';
import '../create_bill/create_bill_ui/create_bill_screen.dart';
import '../create_bill/providers/billing_provider.dart';
import '../home/controllers/home_controller.dart';
import '../home/home_ui/home_screen.dart';
import '../returns/returns_ui/returns_screen.dart';
import '../sales/sales_ui/sales_screen.dart';
import '../settings/settings_ui/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  final int initialIndex;
  final ValueNotifier<int> _currentIndex;

  DashboardScreen({super.key, this.initialIndex = 0})
      : _currentIndex = ValueNotifier<int>(initialIndex);

  void _navigateToHome(BuildContext context) {
    _currentIndex.value = 0;
    context.read<HomeController>().loadPendingDrafts();
    final billingProv = context.read<BillingProvider>();
    final homeCtrl = context.read<HomeController>();
    final companyProv = context.read<CompanyProvider>();
    final companyId = companyProv.selectedCompany?.id;

    companyProv.fetchCompanies().then((_) {
      homeCtrl.setMetricsFromCompany(companyProv.selectedCompany?.billingMetrics);
    });
    billingProv.fetchTodayBillModels(companyId: companyId).then((_) {
      homeCtrl.loadBillsData(billingProv.todayBillModels);
    });
    billingProv.fetchAvailableProducts(companyId: companyId).then((_) {
      homeCtrl.loadAvailableProducts(billingProv.availableProducts);
    });
  }

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    color: Color(0xFFDC2626),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n?.exitApplication ?? 'Exit Application',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.exitConfirmMessage ?? 'Are you sure you want to exit the app?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSubtitle,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textDark,
                          side: const BorderSide(
                            color: Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n?.cancel ?? 'Cancel',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n?.exit ?? 'Exit',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final isKeyboardOpen = keyboardInset > 0;
    final bottomMargin = bottomInset > 0 ? bottomInset + 4 : 12.0;

    return ValueListenableBuilder<int>(
      valueListenable: _currentIndex,
      builder: (context, currentIndex, _) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (currentIndex != 0) {
              _navigateToHome(context);
            } else {
              _showExitConfirmationDialog(context);
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.spaceDarkBlue,
            body: Stack(
              children: [
                // Current Tab Body
                Positioned.fill(
                  child: Builder(
                    builder: (context) {
                      switch (currentIndex) {
                        case 0:
                          return HomeScreen(
                            onNavigateToSales: () => _currentIndex.value = 1,
                            onNavigateToReturns: () => _currentIndex.value = 3,
                          );
                        case 1:
                          return SalesScreen(
                            onBack: () => _navigateToHome(context),
                          );
                        case 3:
                          return ReturnsScreen(
                            onBack: () => _navigateToHome(context),
                          );
                        case 4:
                          return SettingsScreen(
                            onBack: () => _navigateToHome(context),
                          );
                        default:
                          return _buildPlaceholderScreen(_getTitle(currentIndex));
                      }
                    },
                  ),
                ),

                // Floating Bottom Navigation Bar (hidden when keyboard is open)
                if (!isKeyboardOpen)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: bottomMargin,
                    child: CustomBottomNavBar(
                      currentIndex: currentIndex,
                      onTabSelected: (newIndex) {
                        if (newIndex == 0) {
                          _navigateToHome(context);
                        } else {
                          _currentIndex.value = newIndex;
                        }
                      },
                      onAddPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CreateBillScreen(),
                          ),
                        );
                        if (context.mounted) {
                          _navigateToHome(context);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderScreen(String title) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          '$title Page',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textSubtitle,
          ),
        ),
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Sales';
      case 3:
        return 'Returns';
      case 4:
        return 'Settings';
      default:
        return 'RK Plast';
    }
  }
}
