import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../controllers/payment_collection_controller.dart';
import 'add_payment_collection_screen.dart';
import 'widgets/payment_collection_card.dart';

class PaymentCollectionScreen extends StatefulWidget {
  const PaymentCollectionScreen({super.key});

  @override
  State<PaymentCollectionScreen> createState() =>
      _PaymentCollectionScreenState();
}

class _PaymentCollectionScreenState extends State<PaymentCollectionScreen> {
  late final PaymentCollectionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaymentCollectionController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.loadCollections();
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
                        child: RefreshIndicator(
                          color: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          onRefresh: () => _controller.loadCollections(),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                            child: Consumer<PaymentCollectionController>(
                              builder: (context, controller, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Search Bar + Filter Button
                                    _buildSearchAndFilterRow(l10n),
                                    const SizedBox(height: 18),

                                    // 2. Top Two Stat / Metric Cards
                                    _buildMetricCardsRow(l10n),
                                    const SizedBox(height: 24),

                                    // 3. Date Grouped Sections
                                    if (controller.isLoading &&
                                        controller.allCollections.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 40,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      )
                                    else if (controller.errorMessage != null &&
                                        controller.allCollections.isEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 30,
                                          horizontal: 16,
                                        ),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                controller.errorMessage!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Color(0xFFEF4444),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    controller.loadCollections(),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryBlue,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                ),
                                                child: const Text('Retry'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Builder(
                                        builder: (context) {
                                          final sections =
                                              controller.availableSections;

                                          if (sections.isEmpty) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 40,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  l10n.noCollectionsFound,
                                                  style: TextStyle(
                                                    fontSize: 14.5,
                                                    color: Colors.grey.shade500,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: sections.map((section) {
                                              final sectionItems =
                                                  controller.getItemsForSection(section);
                                              if (sectionItems.isEmpty) {
                                                return const SizedBox.shrink();
                                              }

                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 20.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      section,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textDark,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    ListView.separated(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      padding: EdgeInsets.zero,
                                                      itemCount:
                                                          sectionItems.length,
                                                      separatorBuilder:
                                                          (context, index) =>
                                                              const SizedBox(
                                                        height: 12,
                                                      ),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final item =
                                                            sectionItems[index];
                                                        return PaymentCollectionCard(
                                                          item: item,
                                                          onTap: () async {
                                                            final updated =
                                                                await Navigator.of(
                                                              context,
                                                            ).push(
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    AddPaymentCollectionScreen(
                                                                  preselectedBill:
                                                                      item.bill,
                                                                ),
                                                              ),
                                                            );
                                                            if (updated == true) {
                                                              controller
                                                                  .loadCollections();
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          );
                                        },
                                      ),
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

            // 3. Floating Action Button
            Positioned(
              bottom: MediaQuery.paddingOf(context).bottom + 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final updated = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddPaymentCollectionScreen(),
                    ),
                  );
                  if (updated == true) {
                    _controller.loadCollections();
                  }
                },

                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF005CBD),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF005CBD).withValues(alpha: 0.20),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterRow(AppLocalizations l10n) {
    return Row(
      children: [
        // Search textfield
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
            ),
            child: TextField(
              controller: _controller.searchController,
              onChanged: _controller.onSearchChanged,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: l10n.search,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 22,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Filter button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF005CBD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Filter action
              },
              child: const Center(
                child: Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCardsRow(AppLocalizations l10n) {
    return Row(
      children: [
        // Card 1: Total Outstanding
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Warning Icon Box
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/danger_sign.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFEF4444),
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Badge: +12%
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 3,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFFDCFCE7),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: const Text(
                    //     '+12%',
                    //     style: TextStyle(
                    //       fontSize: 11,
                    //       fontWeight: FontWeight.w600,
                    //       color: Color(0xFF16A34A),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.totalOutstanding,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_controller.totalOutstanding.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Card 2: Total Collected
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cash Icon Box
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/sales_1.png',
                          width: 20,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.payments_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Badge: -12%
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8,
                    //     vertical: 3,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFFFEE2E2),
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   child: const Text(
                    //     '-12%',
                    //     style: TextStyle(
                    //       fontSize: 11,
                    //       fontWeight: FontWeight.w600,
                    //       color: Color(0xFFEF4444),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.totalCollected,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${_controller.totalCollected.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E3A8A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
