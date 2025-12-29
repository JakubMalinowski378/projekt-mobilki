import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

import 'transactions_screen.dart';
import 'statistics_screen.dart';
import 'categories_screen.dart';
import 'settings_screen.dart';
import 'transaction_form_screen.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShake;

  final List<Widget> _screens = const [
    TransactionsScreen(),
    StatisticsScreen(),
    CategoriesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initAccelerometer();
  }

  void _initAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      if (_lastShake != null && now.difference(_lastShake!).inMilliseconds < 1000) {
        return;
      }

      final gForce = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      if (gForce > 20) {
        _lastShake = now;
        _onShake();
      }
    });
  }

  void _onShake() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransactionFormScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
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
          NavigationDestination(
            icon: const Icon(Icons.receipt_long),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category),
            label: l10n.categories,
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
