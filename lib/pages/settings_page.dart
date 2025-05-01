import 'package:chatapp/services/preferences_service.dart';
import 'package:chatapp/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final PreferencesService _preferencesService =
      PreferencesService();
  bool _healthReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final healthReminderEnabled =
        await _preferencesService.isHealthReminderEnabled();
    setState(() {
      _healthReminderEnabled = healthReminderEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          // Dark Mode Setting
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode"),
                CupertinoSwitch(
                  value:
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).isDarkMode,
                  onChanged:
                      (value) =>
                          Provider.of<ThemeProvider>(
                            context,
                            listen: false,
                          ).toggleTheme(),
                ),
              ],
            ),
          ),

          // Health Reminder Setting
          Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(
              horizontal: 25,
            ),
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text("Health Reminders"),
                    const SizedBox(height: 4),
                    Text(
                      "Show periodic health tips",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: .7),
                      ),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: _healthReminderEnabled,
                  onChanged: (value) async {
                    await _preferencesService
                        .setHealthReminderEnabled(value);
                    setState(() {
                      _healthReminderEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
