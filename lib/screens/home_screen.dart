import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

import 'dashboard_screen.dart';
import 'statistics_screen.dart';
import 'categories_screen.dart';
import 'currency_rates_screen.dart';
import 'settings_screen.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/flying_money_overlay.dart';
import '../data/services/audio_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  bool _isShaking = false;
  final AudioService _audioService = AudioService();

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatisticsScreen(),
    CategoriesScreen(),
    CurrencyRatesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initGyroscope();
  }

  void _initGyroscope() {
    _gyroscopeSubscription = gyroscopeEventStream().listen((event) {
      final settingsProvider = context.read<SettingsProvider>();
      if (!settingsProvider.shakeAnimationEnabled) {
        return;
      }

      // Detect strong rotation movement (shake with rotation)
      final rotationMagnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      // If device is rotating strongly (> 5 rad/s), trigger money animation
      if (rotationMagnitude > 5.0 && !_isShaking) {
        _isShaking = true;
        _triggerMoneyAnimation();

        // Reset shake flag after cooldown
        Future.delayed(const Duration(milliseconds: 2000), () {
          _isShaking = false;
        });
      }
    });
  }

  void _triggerMoneyAnimation() {
    if (mounted) {
      FlyingMoneyAnimation.show(context);
      _audioService.playShakeMusic();
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: l10n.home),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category),
            label: l10n.categories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.currency_exchange),
            label: l10n.currencyRates,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
