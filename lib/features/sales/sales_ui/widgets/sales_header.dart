import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SalesHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onExportTap;

  const SalesHeader({
    super.key,
    this.onBackTap,
    this.onExportTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Back Button
          GestureDetector(
            onTap: onBackTap ?? () => Navigator.maybePop(context),
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
            l10n?.salesLogs ?? 'Sales Logs',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),

          // White Export/Document Action Button
          GestureDetector(
            onTap: onExportTap,
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
    );
  }
}
