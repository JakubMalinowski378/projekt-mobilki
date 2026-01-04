import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: Text(l10n.darkMode),
            subtitle: Consumer<SettingsProvider>(
              builder: (context, settings, _) => Text(settings.isDarkModeOverride ? 'Forced dark' : 'System default'),
            ),
            value: Provider.of<SettingsProvider>(context).isDarkModeOverride,
            onChanged: (value) => Provider.of<SettingsProvider>(context, listen: false).setDarkModeOverride(value),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              trailing: DropdownButton<Locale>(
                value: settings.locale,
                underline: Container(),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('System'),
                  ),
                  DropdownMenuItem(
                    value: Locale('pl'),
                    child: Text('Polski'),
                  ),
                  DropdownMenuItem(
                    value: Locale('en'),
                    child: Text('English'),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  Provider.of<SettingsProvider>(context, listen: false).setLocale(newLocale);
                },
              ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(l10n.defaultCurrency),
              trailing: DropdownButton<String>(
                value: settings.targetCurrency,
                underline: Container(),
                items: ['PLN', 'USD', 'EUR', 'GBP', 'JPY']
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(currency),
                        ))
                    .toList(),
                onChanged: (String? newCurrency) {
                  if (newCurrency != null) {
                    Provider.of<SettingsProvider>(context, listen: false)
                        .setTargetCurrency(newCurrency);
                  }
                },
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(l10n.notifications),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification settings
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(l10n.biometricAuth),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement biometric settings
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle,
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025',
              );
            },
          ),
        ],
      ),
    );
  }
}
