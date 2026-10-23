import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/localization/locale_provider.dart';
import 'core/services/connectivity_service.dart';
import 'core/theme/app_colors.dart';
import 'core/widgets/no_internet_screen.dart';
import 'features/company/providers/company_provider.dart';
import 'features/create_bill/providers/billing_provider.dart';
import 'features/create_bill/providers/size_master_provider.dart';
import 'features/customer/providers/customer_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/home/controllers/home_controller.dart';
import 'features/login/login_ui/login.dart';
import 'features/login/providers/auth_provider.dart';
import 'features/notification/providers/notification_provider.dart';
import 'features/production/providers/production_provider.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Could not initialize Firebase: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Pre-check auth status before rendering
  final authProvider = AuthProvider();
  await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => CompanyProvider()..fetchCompanies()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()..fetchCustomers()),
        ChangeNotifierProvider(create: (_) => BillingProvider()),
        ChangeNotifierProvider(create: (_) => SizeMasterProvider()),
        ChangeNotifierProvider(create: (_) => HomeController()..loadPendingDrafts()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()..fetchNotifications()),
        ChangeNotifierProvider(create: (_) => ProductionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp(
          navigatorKey: AppConfig.navigatorKey,
          title: 'RK Plast',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'MonaSans',
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryBlue,
              primary: AppColors.primaryBlue,
            ),
          ),
          builder: (context, child) {
            return Consumer<ConnectivityProvider>(
              builder: (context, connectivity, _) {
                return Stack(
                  children: [
                    ?child,
                    if (!connectivity.isConnected)
                      const Positioned.fill(
                        child: Material(
                          child: NoInternetScreen(),
                        ),
                      ),
                  ],
                );
              },
            );
          },
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return authProvider.isAuthenticated
                  ? DashboardScreen()
                  : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

