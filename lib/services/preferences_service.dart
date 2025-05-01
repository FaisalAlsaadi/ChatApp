import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Keys for SharedPreferences
  static const String healthReminderEnabledKey = 'health_reminder_enabled';
  static const String lastReminderShownKey = 'last_reminder_shown';

  // Get SharedPreferences instance
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Check if health reminders are enabled
  Future<bool> isHealthReminderEnabled() async {
    final prefs = await _getPrefs();
    // Default to true if not set
    return prefs.getBool(healthReminderEnabledKey) ?? true;
  }

  // Set health reminder enabled status
  Future<void> setHealthReminderEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(healthReminderEnabledKey, value);
  }

  // Get when the last reminder was shown
  Future<DateTime?> getLastReminderShown() async {
    final prefs = await _getPrefs();
    final timestamp = prefs.getInt(lastReminderShownKey);
    if (timestamp == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Set when the last reminder was shown
  Future<void> setLastReminderShown() async {
    final prefs = await _getPrefs();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(lastReminderShownKey, now);
  }

  // Check if reminder should be shown
  Future<bool> shouldShowReminder() async {
    // If reminders are disabled, don't show
    final enabled = await isHealthReminderEnabled();
    if (!enabled) return false;

    // Get the last time reminder was shown
    final lastShown = await getLastReminderShown();
    
    // If never shown or shown over 24 hours ago, show reminder
    if (lastShown == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastShown);
    
    // Show if 24 hours have passed
    return difference.inHours >= 24;
  }
}