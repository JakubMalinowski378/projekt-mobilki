import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/services/biometric_service.dart';
import '../providers/settings_provider.dart';
import 'home_screen.dart';
import '../l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final BiometricService biometricService;

  const AuthScreen({super.key, required this.biometricService});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);

    // Give SettingsProvider time to load from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 100));

    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.biometricEnabled) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    final isAvailable = await widget.biometricService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      return;
    }

    final authenticated = await widget.biometricService.authenticate();

    setState(() => _isAuthenticating = false);

    if (authenticated && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.authenticateToUnlock,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            if (_isAuthenticating)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _authenticate,
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.biometricAuth),
              ),
          ],
        ),
      ),
    );
  }
}
