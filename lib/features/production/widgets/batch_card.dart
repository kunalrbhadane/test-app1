import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/production_batch_model.dart';

class BatchCard extends StatelessWidget {
  final ProductionBatchModel batch;
  final VoidCallback? onTap;
  final bool isSelected;

  const BatchCard({
    super.key,
    required this.batch,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFinished = batch.isFinished;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Batch Number & Size Key Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        color: AppColors.primaryBlue,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      batch.batchNumber,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    batch.sizeKey.isNotEmpty ? batch.sizeKey : 'Standard',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Middle Stats Row
            Row(
              children: [
                // Net Good Count
                Expanded(
                  child: _buildMetricTile(
                    label: 'Net Good',
                    value: '${batch.netGoodCount}',
                    icon: Icons.check_circle_outline_rounded,
                    valueColor: const Color(0xFF15803D),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Rejection Count
                Expanded(
                  child: _buildMetricTile(
                    label: 'Rejection',
                    value: '${batch.totalRejectionCount}',
                    icon: Icons.cancel_outlined,
                    valueColor: batch.totalRejectionCount > 0
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF64748B),
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: const Color(0xFFE2E8F0),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                // Expected
                Expanded(
                  child: _buildMetricTile(
                    label: 'Expected',
                    value: '${batch.totalPreformPiecesExpected}',
                    icon: Icons.inventory_2_outlined,
                    valueColor: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bottom Row: Stage & Status Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current Stage
                Row(
                  children: [
                    const Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      batch.currentStage.isNotEmpty
                          ? 'Stage: ${batch.currentStage.toUpperCase()}'
                          : 'Stage: N/A',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isFinished
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    batch.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isFinished
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Icon(icon, size: 13, color: valueColor),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
