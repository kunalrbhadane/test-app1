import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SalesFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final List<String> options;
  final ValueChanged<String> onSelected;

  const SalesFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.options,
    required this.onSelected,
  });

  String _getLocalizedOptionLabel(BuildContext context, String option) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return option;
    switch (option.toLowerCase()) {
      case 'all':
        return l10n.filterAll;
      case 'pakka bill':
        return l10n.pakkaBill;
      case 'kaccha bill':
        return l10n.kacchaBill;
      default:
        return option;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((option) {
        final isSelected = selectedFilter == option;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _getLocalizedOptionLabel(context, option),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
