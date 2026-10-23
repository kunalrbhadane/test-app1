import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class MetricCard extends StatefulWidget {
  final Widget icon;
  final String title;
  final String value;
  final String percentageChange;
  final bool isPositive;
  final bool isAlert;
  final VoidCallback? onTap;

  const MetricCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.percentageChange,
    this.isPositive = true,
    this.isAlert = false,
    this.onTap,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
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

    if (widget.isAlert) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant MetricCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAlert != oldWidget.isAlert) {
      if (widget.isAlert) {
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final glowAlpha =
            widget.isAlert ? (0.08 + 0.10 * _pulseAnimation.value) : 0.04;
        final borderColor = widget.isAlert
            ? Color.lerp(
                const Color(0xFFFCA5A5),
                const Color(0xFFEF4444),
                _pulseAnimation.value,
              )!
            : const Color(0xFFF1F5F9);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: widget.isAlert
                    ? const Color(0xFFFFF8F8)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: borderColor,
                  width: widget.isAlert ? 1.5 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isAlert
                        ? const Color(0xFFEF4444).withValues(alpha: glowAlpha)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: widget.isAlert ? 16 : 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon + Percentage / Alert Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.isAlert
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                          border: widget.isAlert
                              ? Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 1.0,
                                )
                              : null,
                        ),
                        child: Center(
                          child: widget.isAlert
                              ? Transform.scale(
                                  scale: 1.0 + 0.08 * _pulseAnimation.value,
                                  child: widget.icon,
                                )
                              : widget.icon,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isAlert
                              ? const Color(0xFFFEE2E2)
                              : widget.isPositive
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                          border: widget.isAlert
                              ? Border.all(
                                  color: const Color(0xFFFECACA),
                                  width: 0.8,
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.isAlert) ...[
                              const Icon(
                                Icons.warning_rounded,
                                size: 12,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              widget.percentageChange,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: widget.isAlert
                                    ? const Color(0xFFDC2626)
                                    : widget.isPositive
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isAlert
                          ? const Color(0xFFB91C1C)
                          : AppColors.textLabel,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Value
                  ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      colors: widget.isAlert
                          ? const [Color(0xFFDC2626), Color(0xFF991B1B)]
                          : const [Color(0xFF012258), Color(0xFF013B85)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Text(
                      widget.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
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
