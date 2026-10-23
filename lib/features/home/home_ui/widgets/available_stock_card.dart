import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../create_bill/models/available_product_model.dart';

class AvailableStockCard extends StatefulWidget {
  final AvailableProductModel product;
  final VoidCallback? onTap;

  const AvailableStockCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<AvailableStockCard> createState() => _AvailableStockCardState();
}

class _AvailableStockCardState extends State<AvailableStockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _checkAndAnimate();
  }

  @override
  void didUpdateWidget(covariant AvailableStockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAndAnimate();
  }

  void _checkAndAnimate() {
    final isLowStock = widget.product.currentStock <= widget.product.minimumStock &&
        widget.product.currentStock > 0;
    final isOutOfStock = widget.product.currentStock == 0;

    if (isLowStock || isOutOfStock) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final product = widget.product;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: product.salePrice % 1 == 0 ? 0 : 2,
    );
    final numberFormat = NumberFormat('#,##,###');

    final bool isLowStock =
        product.currentStock <= product.minimumStock && product.currentStock > 0;
    final bool isOutOfStock = product.currentStock == 0;

    final Color statusBg = isOutOfStock
        ? const Color(0xFFFEE2E2)
        : isLowStock
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFDCFCE7);

    final Color statusColor = isOutOfStock
        ? const Color(0xFFDC2626)
        : isLowStock
            ? const Color(0xFFD97706)
            : const Color(0xFF16A34A);

    final String statusText = isOutOfStock
        ? l10n.outOfStock
        : isLowStock
            ? '${l10n.lowStock} (${l10n.minStock}: ${numberFormat.format(product.minimumStock)})'
            : l10n.inStock;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final pulseVal = (isLowStock || isOutOfStock) ? _pulseAnimation.value : 0.0;

        final Color borderColor = isOutOfStock
            ? Color.lerp(const Color(0xFFFECACA), const Color(0xFFEF4444), pulseVal)!
            : isLowStock
                ? Color.lerp(const Color(0xFFFDE68A), const Color(0xFFF59E0B), pulseVal)!
                : const Color(0xFFE2E8F0);

        final List<BoxShadow> cardShadows = isOutOfStock
            ? [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.06 + 0.12 * pulseVal),
                  blurRadius: 8 + 6 * pulseVal,
                  spreadRadius: 0.5 * pulseVal,
                  offset: const Offset(0, 3),
                ),
              ]
            : isLowStock
                ? [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.06 + 0.12 * pulseVal),
                      blurRadius: 8 + 6 * pulseVal,
                      spreadRadius: 0.5 * pulseVal,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ];        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 9.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: (isLowStock || isOutOfStock) ? (1.0 + 0.4 * pulseVal) : 1.0,
                ),
                boxShadow: cardShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Top Row: Product ID / Category + Packaging Badge + Status Pill
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 3,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Product ID Badge
                            if (product.productId.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  product.productId.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),

                            // Packaging Rule Key Badge
                            if (product.packagingRuleKey.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/bottle.png',
                                      width: 11,
                                      height: 11,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 10,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      product.packagingRuleKey,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0284C7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Status Pill with alert animation
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? Color.lerp(
                                  const Color(0xFFFEF3C7),
                                  const Color(0xFFFDE68A),
                                  pulseVal,
                                )
                              : isOutOfStock
                                  ? Color.lerp(
                                      const Color(0xFFFEE2E2),
                                      const Color(0xFFFECACA),
                                      pulseVal,
                                    )
                                  : statusBg,
                          borderRadius: BorderRadius.circular(16),
                          border: (isLowStock || isOutOfStock)
                              ? Border.all(
                                  color: isLowStock
                                      ? const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.3 + 0.5 * pulseVal)
                                      : const Color(0xFFEF4444)
                                          .withValues(alpha: 0.3 + 0.5 * pulseVal),
                                  width: 0.8,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOutOfStock) ...[
                              Image.asset(
                                'assets/images/out-of-stock.png',
                                width: 11,
                                height: 11,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3.5),
                            ] else if (isLowStock) ...[
                              Transform.scale(
                                scale: 0.85 + 0.25 * pulseVal,
                                child: Image.asset(
                                  'assets/images/danger_sign.png',
                                  width: 12,
                                  height: 12,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.warning_amber_rounded,
                                    size: 12,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3.5),
                            ] else ...[
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  // 2. Product Name & Stock Quantity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? const Color(0xFFFEE2E2)
                              : isLowStock
                                  ? const Color(0xFFFEF3C7)
                                  : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isOutOfStock
                                ? const Color(0xFFFECACA)
                                : isLowStock
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFFDBEAFE),
                            width: 0.8,
                          ),
                        ),
                        child: Center(
                          child: isOutOfStock
                              ? Image.asset(
                                  'assets/images/out-of-stock.png',
                                  width: 18,
                                  height: 18,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.remove_shopping_cart_outlined,
                                    color: Color(0xFFDC2626),
                                    size: 16,
                                  ),
                                )
                              : isLowStock
                                  ? Transform.scale(
                                      scale: 0.9 + 0.15 * pulseVal,
                                      child: Image.asset(
                                        'assets/images/danger_sign.png',
                                        width: 17,
                                        height: 17,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => const Icon(
                                          Icons.warning_amber_rounded,
                                          color: Color(0xFFD97706),
                                          size: 16,
                                        ),
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/packages.png',
                                      width: 17,
                                      height: 17,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.inventory_2_outlined,
                                        color: Color(0xFF0284C7),
                                        size: 16,
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name.isNotEmpty
                                  ? product.name[0].toUpperCase() +
                                      product.name.substring(1)
                                  : 'Product',
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (product.category.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                product.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSubtitle,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Stock Count (Gradient / Bold)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF012258), Color(0xFF013B85)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              '${numberFormat.format(product.currentStock)} ${product.unit.isNotEmpty ? product.unit : 'NOS'}',
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.availableStock,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLabel,
                                ),
                              ),
                              if (product.minimumStock > 0) ...[
                                const Text(
                                  ' • ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                                if (isLowStock) ...[
                                  Image.asset(
                                    'assets/images/danger_sign.png',
                                    width: 10,
                                    height: 10,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 10,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                  const SizedBox(width: 2.5),
                                ],
                                Text(
                                  '${l10n.minStock}: ${numberFormat.format(product.minimumStock)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isLowStock
                                        ? const Color(0xFFD97706)
                                        : AppColors.textSubtitle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

                  const Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 5),

                  // 3. Footer Details: Price, GST, Pcs per Box, HSN
                  Row(
                    children: [
                      // Sale Price
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${l10n.price}: ',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textLabel,
                            ),
                          ),
                          Text(
                            currencyFormat.format(product.salePrice),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),

                      // GST
                      if (product.gstPercent > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            '${l10n.gst} ${product.gstPercent.toStringAsFixed(product.gstPercent % 1 == 0 ? 0 : 1)}%',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],

                      // Pcs per Box
                      if (product.pcsPerBox > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• ${product.pcsPerBox} ${l10n.pcs}/${l10n.box}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // HSN Code
                      if (product.hsnCode.isNotEmpty)
                        Text(
                          '${l10n.hsn}: ${product.hsnCode}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
