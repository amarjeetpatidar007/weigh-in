import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weigh_in/main.dart';
import '../services/user_provider.dart';

class EditNotificationTimeForm extends StatelessWidget {
  EditNotificationTimeForm({super.key});

  Future<void> _pickTime(BuildContext context) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final currentTime = provider.notificationTime ?? TimeOfDay.now();

    // Display time picker dialog
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (pickedTime != null) {
      provider.updateNotificationTime(pickedTime);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification time updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final notificationTime = provider.notificationTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Notification Time'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Current Notification Time: ${notificationTime?.format(context) ?? "Not set"}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Button to pick new time
            ElevatedButton(
              onPressed: () {
                _pickTime(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Set New Time',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
