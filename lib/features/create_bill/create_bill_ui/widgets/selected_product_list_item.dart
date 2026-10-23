import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/selected_product_model.dart';

class SelectedProductListItem extends StatelessWidget {
  final SelectedProductItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const SelectedProductListItem({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasGst = item.gstPercent > 0;
    final isAtStockLimit = item.currentStock > 0 && item.quantity >= item.currentStock;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Product Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 1),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/bottle.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF0284C7),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Product Name, Rate, and Mini Stepper
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBody,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Text(
                      '₹${item.rate.toStringAsFixed(2)} / ${item.unit ?? 'NOS'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (hasGst)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GST ${item.gstPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    if (item.batchNumber != null && item.batchNumber!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Text(
                          'Batch: ${item.batchNumber}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    if (item.currentStock > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isAtStockLimit
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stock: ${item.currentStock}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isAtStockLimit
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Stepper
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MiniCircleBtn(
                      icon: Icons.remove_rounded,
                      onTap: onDecrement,
                    ),
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 28),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: onEdit != null ? const Color(0xFFF1F5F9) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: isAtStockLimit
                                  ? const Color(0xFFEF4444)
                                  : AppColors.textBody,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _MiniCircleBtn(
                      icon: Icons.add_rounded,
                      onTap: onIncrement,
                      isDisabled: isAtStockLimit,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // 3. Amount & Action Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${item.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null) ...[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primaryBlue,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onDelete,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDisabled;

  const _MiniCircleBtn({
    required this.icon,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isDisabled
                ? const Color(0xFFF1F5F9)
                : const Color(0xFFF0F9FF),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFFBAE6FD),
              width: 1.0,
            ),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 14,
              color: isDisabled
                  ? const Color(0xFFCBD5E1)
                  : AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}
