import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_primary_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../dashboard/dashboard_screen.dart';
import '../controllers/login_controller.dart';
import 'widgets/starry_header_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final headerHeight = topPadding + 110.0;
    final controller = Provider.of<LoginController>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.spaceDarkBlue,
      body: Stack(
        children: [
          // 1. Top Decorative Starry Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 40,
            child: StarryHeaderBackground(height: headerHeight + 40),
          ),

          // 2. Main Scrollable Form Surface
          Positioned.fill(
            top: headerHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24.0),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const _FallbackLogo(),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Title
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF012258),
                              Color(0xFF013B85),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            l10n.getStartedNow,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Subtitle
                        Text(
                          l10n.logInToExplore,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSubtitle,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Contact No Field
                        CustomTextField(
                          label: l10n.contactNo,
                          hintText: l10n.enterTenDigitMobile,
                          controller: controller.contactController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          prefix: const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Text(
                              '+91 |',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textBody,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterContactNo;
                            }
                            if (value.trim().length < 10) {
                              return l10n.enterValidMobile;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Field
                        Consumer<LoginController>(
                          builder: (context, loginCtrl, _) {
                            return CustomTextField(
                              label: l10n.password,
                              hintText: l10n.enterPassword,
                              controller: loginCtrl.passwordController,
                              obscureText: loginCtrl.obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  loginCtrl.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSubtitle,
                                  size: 20,
                                ),
                                onPressed:
                                    loginCtrl.togglePasswordVisibility,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterPassword;
                                }
                                return null;
                              },
                              onSubmitted: (_) => _handleLogin(context, loginCtrl),
                            );
                          },
                        ),
                        const SizedBox(height: 8),

                        // Error Message Display
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            if (authProvider.errorMessage == null ||
                                authProvider.errorMessage!.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFCA5A5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: AppColors.borderError,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: const TextStyle(
                                        color: AppColors.borderError,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Log In Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return CustomPrimaryButton(
                              text: l10n.login,
                              isLoading: authProvider.isLoading,
                              onPressed: () => _handleLogin(context, controller),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLogin(BuildContext context, LoginController controller) async {
    FocusScope.of(context).unfocus();
    final success = await controller.login(context);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          backgroundColor: AppColors.primaryBlue,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => DashboardScreen()));
    }
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.spaceNavy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'RK PLAST',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
