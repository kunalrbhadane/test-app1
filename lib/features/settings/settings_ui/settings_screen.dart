import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../login/login_ui/widgets/starry_header_background.dart';
import '../../login/providers/auth_provider.dart';
import 'widgets/language_selector_sheet.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const SettingsScreen({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.spaceDarkBlue,
      body: Stack(
        children: [
          // 1. Starry Sky Top Background
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: StarryHeaderBackground(height: 200),
          ),

          // 2. Main Content Body
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: onBack ?? () => Navigator.maybePop(context),
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

                      // Title
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 44.0),
                            child: Text(
                              l10n?.settingsAndPrivacy ?? 'Setting & Privacy',
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 140),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- SECTION 1: ACCOUNT ---
                            Text(
                              l10n?.account ?? 'ACCOUNT',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Language Selection Tile
                            SettingsTile(
                              icon: Icons.language_rounded,
                              title: l10n?.language ?? 'Language / भाषा',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  localeProvider.isMarathi
                                      ? 'मराठी (MR)'
                                      : 'English (EN)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              onTap: () => LanguageSelectorSheet.show(context),
                            ),

                            SettingsTile(
                              icon: Icons.print_outlined,
                              title: l10n?.printerSettings ?? 'Printer Settings',
                              onTap: () {},
                            ),
                            SettingsTile(
                              icon: Icons.help_outline_rounded,
                              title: l10n?.helpAndSupport ?? 'Help & Support',
                              onTap: () {},
                            ),
                            SettingsTile(
                              icon: Icons.info_outline_rounded,
                              title: l10n?.appInformation ?? 'App Information',
                              onTap: () {},
                            ),
                            const SizedBox(height: 18),

                            // --- SECTION 2: OTHER SETTING ---
                            Text(
                              l10n?.otherSettings ?? 'OTHER SETTING',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SettingsTile(
                              icon: Icons.article_outlined,
                              title: l10n?.termsAndConditions ?? 'Terms & Conditions',
                              onTap: () {},
                            ),
                            SettingsTile(
                              icon: Icons.shield_outlined,
                              title: l10n?.privacyPolicy ?? 'Privacy Policy',
                              onTap: () {},
                            ),
                            const SizedBox(height: 32),

                            // --- LOGOUT BUTTON ---
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => _showLogoutDialog(context, l10n),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFEE2E2),
                                  foregroundColor: const Color(0xFFEF4444),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  (l10n?.logout ?? 'LOGOUT').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n?.confirmLogout ?? 'Confirm Logout',
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        ),
        content: Text(
          l10n?.logoutConfirmationMessage ??
              'Are you sure you want to log out of RK Plast Billing?',
          style: const TextStyle(color: AppColors.textSubtitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n?.cancel ?? 'Cancel',
              style: const TextStyle(color: AppColors.textLabel),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n?.logout ?? 'Logout'),
          ),
        ],
      ),
    );
  }
}

