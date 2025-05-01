import 'package:chatapp/services/preferences_service.dart';
import 'package:flutter/material.dart';

class HealthReminderDialog extends StatelessWidget {
  const HealthReminderDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(Icons.favorite, color: Colors.red, size: 60),
          const SizedBox(height: 16),

          // Title
          Text(
            "Health Reminder",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Health tips text
          Text(
            "Remember to take care of yourself while chatting:\n\n"
            "• Take regular screen breaks\n"
            "• Maintain good posture\n"
            "• Stay hydrated\n"
            "• Stretch occasionally\n"
            "• Protect your eyes with proper lighting",
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Buttons
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              // Close button
              ElevatedButton(
                onPressed: () {
                  // Just record that we showed the reminder
                  PreferencesService()
                      .setLastReminderShown();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                ),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              // Never show again button
              OutlinedButton.icon(
                onPressed: () async {
                  // Disable health reminders
                  await PreferencesService()
                      .setHealthReminderEnabled(false);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check),
                label: const Text("Don't show again"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Static method to show the dialog
  static Future<void> show(BuildContext context) async {
    // Check if we should show the reminder
    final shouldShow =
        await PreferencesService().shouldShowReminder();

    if (shouldShow) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext context) =>
                HealthReminderDialog(),
      );
    }
  }
}
