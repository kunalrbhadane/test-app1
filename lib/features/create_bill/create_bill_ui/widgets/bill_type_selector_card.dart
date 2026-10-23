import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BillTypeSelectorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final bool isSelected;
  final VoidCallback onTap;
  final String? imagePath;
  final bool isEnabled;

  const BillTypeSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.isSelected,
    required this.onTap,
    this.imagePath,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: isEnabled ? const Color(0xFFF4F9FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected && isEnabled
                ? AppColors.primaryBlue
                : const Color(0xFFE2E8F0).withValues(alpha: 0.7),
            width: isSelected && isEnabled ? 1.4 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? const Color(0xFFE0F2FE)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: imagePath != null
                          ? Image.asset(
                              imagePath!,
                              width: 24,
                              height: 24,
                              color: isEnabled ? null : const Color(0xFF94A3B8),
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.receipt_rounded,
                                color: isEnabled
                                    ? const Color(0xFF0284C7)
                                    : const Color(0xFF94A3B8),
                                size: 24,
                              ),
                            )
                          : Icon(
                              Icons.receipt_rounded,
                              color: isEnabled
                                  ? const Color(0xFF0284C7)
                                  : const Color(0xFF94A3B8),
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isEnabled
                                    ? titleColor
                                    : const Color(0xFF94A3B8),
                                letterSpacing: -0.1,
                              ),
                            ),
                            if (!isEnabled) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Disabled',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isEnabled
                                ? AppColors.textBody
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Radio Button Circle
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected && isEnabled
                            ? AppColors.primaryBlue
                            : const Color(0xFF94A3B8),
                        width: isSelected && isEnabled ? 6.5 : 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
