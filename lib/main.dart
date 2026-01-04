import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/settings_provider.dart';
import 'data/database/database.dart';
import 'data/services/biometric_service.dart';
import 'data/services/currency_service.dart';
import 'data/services/notification_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/currency_provider.dart';
import 'screens/auth_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final database = AppDatabase();
  final biometricService = BiometricService();
  final currencyService = CurrencyService();
  final notificationService = NotificationService();
  
  await notificationService.initialize();
  
  runApp(MyApp(
    database: database,
    biometricService: biometricService,
    currencyService: currencyService,
  ));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;
  final BiometricService biometricService;
  final CurrencyService currencyService;

  const MyApp({
    super.key,
    required this.database,
    required this.biometricService,
    required this.currencyService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(database),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(database),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(database),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(database, currencyService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        Provider.value(value: biometricService),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Finance Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settings.isDarkModeOverride ? ThemeMode.dark : ThemeMode.system,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pl'),
          ],
          home: AuthScreen(biometricService: biometricService),
        ),
      ),
    );
  }
}
